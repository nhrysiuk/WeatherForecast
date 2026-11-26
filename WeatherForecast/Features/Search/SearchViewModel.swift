import Domain
import Foundation
import Observation

@Observable
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case invalid(CityNameValidationError)
        case loading
        case results([City])
        case failed(WeatherError)
    }

    private(set) var state = State.idle

    private let citySearch: any CitySearching
    private let debounce: Duration

    init(citySearch: any CitySearching, debounce: Duration = .milliseconds(300)) {
        self.citySearch = citySearch
        self.debounce = debounce
    }

    func search(for query: String) async {
        let name: String?
        do throws(CityNameValidationError) {
            name = try CityNameValidator.validate(query)
        } catch {
            state = .invalid(error)
            return
        }
        guard let name else {
            state = .idle
            return
        }

        state = .loading
        do {
            try await Task.sleep(for: debounce)
            let cities = try await citySearch.searchCities(named: name)
            try Task.checkCancellation()
            state = .results(cities)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(WeatherError(error))
        }
    }
}
