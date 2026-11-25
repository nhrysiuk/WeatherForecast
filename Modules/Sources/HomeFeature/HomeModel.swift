import Domain
import Foundation
import Observation
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WeatherForecast", category: "Home")

@Observable
public final class HomeModel {
    public enum HistoryState: Equatable {
        case loading
        case loaded
        case failed
    }

    public enum SearchState: Equatable {
        case idle
        case invalid(CityNameValidationError)
        case loading
        case results([City])
        case failed(WeatherError)
    }

    public var query = ""
    public private(set) var history = SearchHistory()
    public private(set) var historyState = HistoryState.loading
    public private(set) var searchState = SearchState.idle

    public var isHistoryFull: Bool {
        history.cities.count >= SearchHistory.limit
    }

    private let citySearch: any CitySearching
    private let historyStore: any SearchHistoryStoring
    private let debounce: Duration

    public init(
        citySearch: any CitySearching,
        historyStore: any SearchHistoryStoring,
        debounce: Duration = .milliseconds(300)
    ) {
        self.citySearch = citySearch
        self.historyStore = historyStore
        self.debounce = debounce
    }

    public func loadHistory() async {
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

    public func search() async {
        let name: String
        do throws(CityNameValidationError) {
            name = try CityNameValidator().validate(query)
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

    public func save(_ city: City) async {
        await updateHistory { _ = $0.record(city) }
    }

    public func remove(atOffsets offsets: IndexSet) async {
        await updateHistory { $0.remove(atOffsets: offsets) }
    }

    public func move(fromOffsets source: IndexSet, toOffset destination: Int) async {
        await updateHistory { $0.move(fromOffsets: source, toOffset: destination) }
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
