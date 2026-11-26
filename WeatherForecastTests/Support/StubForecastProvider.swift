import Domain

actor StubForecastProvider: ForecastProviding {
    private let forecast: Forecast?
    private var failures: [WeatherError]
    private(set) var requestedForecasts: [Coordinate] = []

    init(forecast: Forecast? = nil, failures: [WeatherError] = []) {
        self.forecast = forecast
        self.failures = failures
    }

    func forecast(for coordinate: Coordinate) throws -> Forecast {
        requestedForecasts.append(coordinate)
        try failIfNeeded()
        guard let forecast else { throw WeatherError.server }
        return forecast
    }

    private func failIfNeeded() throws {
        guard !failures.isEmpty else { return }
        throw failures.removeFirst()
    }
}
