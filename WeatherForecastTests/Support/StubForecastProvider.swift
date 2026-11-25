import Domain

actor StubForecastProvider: ForecastProviding {
    private let forecast: Forecast?
    private let summary: WeatherSummary?
    private var failures: [WeatherError]
    private(set) var requestedForecasts: [Coordinate] = []
    private(set) var requestedCoordinates: [[Coordinate]] = []

    init(forecast: Forecast? = nil, summary: WeatherSummary? = nil, failures: [WeatherError] = []) {
        self.forecast = forecast
        self.summary = summary
        self.failures = failures
    }

    func forecast(for coordinate: Coordinate) throws -> Forecast {
        requestedForecasts.append(coordinate)
        try failIfNeeded()
        guard let forecast else { throw WeatherError.server }
        return forecast
    }

    func summaries(for coordinates: [Coordinate]) throws -> [Coordinate: WeatherSummary] {
        requestedCoordinates.append(coordinates)
        try failIfNeeded()
        guard let summary else { return [:] }
        return Dictionary(uniqueKeysWithValues: coordinates.map { ($0, summary) })
    }

    private func failIfNeeded() throws {
        guard !failures.isEmpty else { return }
        throw failures.removeFirst()
    }
}
