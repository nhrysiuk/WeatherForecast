/// Finds cities by name.
public protocol CitySearching: Sendable {
    /// Returns matching cities, best match first. An empty array means no matches.
    ///
    /// - Throws: `WeatherError`, or `CancellationError` when the task is cancelled.
    func searchCities(named name: String) async throws -> [City]
}
