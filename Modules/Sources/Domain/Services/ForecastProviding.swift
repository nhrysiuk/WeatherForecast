public protocol ForecastProviding: Sendable {
    func forecast(for coordinate: Coordinate) async throws -> Forecast
}
