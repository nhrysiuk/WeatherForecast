import Domain
import Foundation
import Observation
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WeatherForecast", category: "Forecast")

@Observable
final class ForecastViewModel {
    enum State: Equatable {
        case loading
        case loaded(Forecast)
        case failed(WeatherError)
    }

    let city: City
    private(set) var state = State.loading

    private let forecastProvider: any ForecastProviding

    init(city: City, forecastProvider: any ForecastProviding) {
        self.city = city
        self.forecastProvider = forecastProvider
    }

    func load() async {
        if case .loaded = state { return }
        state = .loading
        do {
            state = .loaded(try await forecastProvider.forecast(for: city.coordinate))
        } catch is CancellationError {
        } catch {
            logger.error("Loading forecast failed: \(String(describing: error), privacy: .public)")
            state = .failed(error as? WeatherError ?? .server)
        }
    }
}
