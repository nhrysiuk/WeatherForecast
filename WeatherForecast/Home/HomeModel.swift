import Domain
import Foundation
import Observation
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WeatherForecast", category: "Home")

@Observable
final class HomeModel {
    enum HistoryState: Equatable {
        case loading
        case loaded
        case failed
    }

    enum SearchState: Equatable {
        case idle
        case invalid(CityNameValidationError)
        case loading
        case results([City])
        case failed(WeatherError)
    }

    var query = ""
    private(set) var history = SearchHistory()
    private(set) var historyState = HistoryState.loading
    private(set) var searchState = SearchState.idle
    private(set) var summaries: [Coordinate: WeatherSummary] = [:]
    private(set) var summariesFailed = false

    private let citySearch: any CitySearching
    private let historyStore: any SearchHistoryStoring
    let forecastProvider: any ForecastProviding
    private let debounce: Duration

    init(
        citySearch: any CitySearching,
        historyStore: any SearchHistoryStoring,
        forecastProvider: any ForecastProviding,
        debounce: Duration = .milliseconds(300)
    ) {
        self.citySearch = citySearch
        self.historyStore = historyStore
        self.forecastProvider = forecastProvider
        self.debounce = debounce
    }

    func loadHistory() async {
        guard historyState != .loaded else { return }
        historyState = .loading
        do {
            history = try await historyStore.load()
            historyState = .loaded
        } catch {
            logger.error("Loading history failed: \(String(describing: error), privacy: .public)")
            historyState = .failed
        }
    }

    func loadSummaries() async {
        let missing = history.cities.map(\.coordinate).filter { summaries[$0] == nil }
        guard !missing.isEmpty else { return }
        summariesFailed = false
        do {
            summaries.merge(try await forecastProvider.summaries(for: missing)) { $1 }
        } catch is CancellationError {
        } catch {
            logger.error("Loading weather summaries failed: \(String(describing: error), privacy: .public)")
            summariesFailed = true
        }
    }

    func search() async {
        let name: String
        do throws(CityNameValidationError) {
            name = try CityNameValidator.validate(query)
        } catch .tooShort {
            searchState = .idle
            return
        } catch {
            searchState = .invalid(error)
            return
        }

        searchState = .loading
        do {
            try await Task.sleep(for: debounce)
            searchState = .results(try await citySearch.searchCities(named: name))
        } catch is CancellationError {
        } catch {
            searchState = .failed(error as? WeatherError ?? .server)
        }
    }

    func save(_ city: City) async {
        await updateHistory { $0.record(city) }
    }

    func remove(atOffsets offsets: IndexSet) async {
        await updateHistory { $0.remove(atOffsets: offsets) }
    }

    private func updateHistory(_ change: (inout SearchHistory) -> Void) async {
        guard historyState == .loaded else { return }
        var updated = history
        change(&updated)
        guard updated != history else { return }
        history = updated
        do {
            try await historyStore.save(history)
        } catch {
            logger.error("Saving history failed: \(String(describing: error), privacy: .public)")
        }
    }
}
