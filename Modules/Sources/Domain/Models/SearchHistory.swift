public struct SearchHistory: Equatable, Sendable {
    public static let defaultLimit = 10

    public private(set) var cities: [City]
    public let limit: Int

    public init(cities: [City] = [], limit: Int = defaultLimit) {
        precondition(limit > 0, "SearchHistory limit must be positive")
        var seen = Set<City.ID>()
        self.cities = Array(cities.filter { seen.insert($0.id).inserted }.prefix(limit))
        self.limit = limit
    }

    public mutating func record(_ city: City) {
        cities.removeAll { $0.id == city.id }
        cities.insert(city, at: 0)
        if cities.count > limit {
            cities.removeLast(cities.count - limit)
        }
    }
}
