import Domain

actor StubForecastProvider: ForecastProviding {
    struct UnexpectedCall: Error {}

    private let summary: WeatherSummary?
    private var remainingFailures: Int
    private(set) var requestedCoordinates: [[Coordinate]] = []

    init(summary: WeatherSummary? = nil, failures: Int = 0) {
        self.summary = summary
        remainingFailures = failures
    }

    func forecast(for coordinate: Coordinate) throws -> Forecast {
        throw UnexpectedCall()
    }

    func summaries(for coordinates: [Coordinate]) throws -> [Coordinate: WeatherSummary] {
        requestedCoordinates.append(coordinates)
        guard remainingFailures == 0 else {
            remainingFailures -= 1
            throw WeatherError.offline
        }
        guard let summary else { return [:] }
        return Dictionary(uniqueKeysWithValues: coordinates.map { ($0, summary) })
    }
}
