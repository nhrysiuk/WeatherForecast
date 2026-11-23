/// Failures that the UI knows how to present.
///
/// Data sources translate transport and decoding errors into these cases,
/// so features never deal with `URLError` or HTTP status codes.
public enum WeatherError: Error, Hashable, Sendable {
    /// No connection, or the connection dropped mid-request.
    case offline
    /// The server answered with an error.
    case server
    /// The server answered, but not with something we understand.
    case invalidResponse
}
