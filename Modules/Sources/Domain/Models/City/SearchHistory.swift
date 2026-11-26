import Foundation

public struct SearchHistory: Equatable, Sendable {
    public static let limit = 20

    public private(set) var cities: [City]

    public init(cities: [City] = []) {
        var seen = Set<City.ID>()
        self.cities = cities.filter { seen.insert($0.id).inserted }
    }

    public mutating func record(_ city: City) {
        cities.removeAll { $0.id == city.id }
        cities.insert(city, at: 0)
        cities = Array(cities.prefix(Self.limit))
    }

    public mutating func remove(atOffsets offsets: IndexSet) {
        for index in offsets.reversed() {
            cities.remove(at: index)
        }
    }
}
