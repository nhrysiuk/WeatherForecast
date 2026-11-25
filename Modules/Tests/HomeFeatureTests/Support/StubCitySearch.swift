import Domain

struct StubCitySearch: CitySearching {
    struct UnexpectedCall: Error {}

    static let unexpected = StubCitySearch { _ in throw UnexpectedCall() }

    var results: @Sendable (String) async throws -> [City]

    func searchCities(named name: String) async throws -> [City] {
        try await results(name)
    }
}
