import Domain
import Foundation
import Observation
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WeatherForecast", category: "History")

@Observable
final class HistoryViewModel {
    private(set) var summaries: [Coordinate: WeatherSummary] = [:]
    private(set) var summariesFailed = false

    private let forecastProvider: any ForecastProviding

    init(forecastProvider: any ForecastProviding) {
        self.forecastProvider = forecastProvider
    }

    func loadSummaries(for coordinates: [Coordinate]) async {
        let missing = coordinates.filter { summaries[$0] == nil }
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
}
