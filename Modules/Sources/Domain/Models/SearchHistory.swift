import Foundation

public struct SearchHistory: Equatable, Sendable {
    public enum RecordResult: Equatable, Sendable {
        case added
        case alreadySaved
        case full
    }

    public static let limit = 20

    public private(set) var cities: [City]

    public init(cities: [City] = []) {
        var seen = Set<City.ID>()
        self.cities = cities.filter { seen.insert($0.id).inserted }
    }

    public mutating func record(_ city: City) -> RecordResult {
        if let index = cities.firstIndex(where: { $0.id == city.id }) {
            cities[index] = city
            return .alreadySaved
        }
        guard cities.count < Self.limit else {
            return .full
        }
        cities.insert(city, at: 0)
        return .added
    }

    public mutating func remove(atOffsets offsets: IndexSet) {
        for index in offsets.reversed() {
            cities.remove(at: index)
        }
    }

    public mutating func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        let moving = source.map { cities[$0] }
        let insertionIndex = destination - source.count(in: 0..<destination)
        remove(atOffsets: source)
        cities.insert(contentsOf: moving, at: insertionIndex)
    }
}
