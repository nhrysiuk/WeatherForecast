public enum WeatherError: Error {
    case offline
    case server

    public init(_ error: any Error) {
        self = error as? WeatherError ?? .server
    }
}
