/// Provides the weather forecast for a location.
public protocol ForecastProviding: Sendable {
    /// - Throws: `WeatherError`, or `CancellationError` when the task is cancelled.
    func forecast(for coordinate: Coordinate) async throws -> Forecast
}
