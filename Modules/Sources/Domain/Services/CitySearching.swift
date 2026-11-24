public protocol CitySearching: Sendable {
    func searchCities(named name: String) async throws -> [City]
}
