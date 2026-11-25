public protocol ForecastProviding: Sendable {
    func forecast(for coordinate: Coordinate) async throws -> Forecast
    func summaries(for coordinates: [Coordinate]) async throws -> [Coordinate: WeatherSummary]
}
