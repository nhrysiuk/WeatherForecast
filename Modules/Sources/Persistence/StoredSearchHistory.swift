import Domain
import Foundation

struct StoredSearchHistory: Codable {
    struct StoredCity: Codable {
        let id: Int
        let name: String
        let region: String?
        let countryCode: String?
        let latitude: Double
        let longitude: Double
    }

    private struct Header: Decodable {
        let version: Int
    }

    static let currentVersion = 1

    let version: Int
    let cities: [StoredCity]

    init(_ history: SearchHistory) {
        version = Self.currentVersion
        cities = history.cities.map(StoredCity.init)
    }

    static func decode(from data: Data) throws -> StoredSearchHistory {
        let decoder = JSONDecoder()
        let version = try decoder.decode(Header.self, from: data).version
        guard version == currentVersion else {
            throw SearchHistoryStoreError.unsupportedVersion(version)
        }
        return try decoder.decode(StoredSearchHistory.self, from: data)
    }

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }

    func makeHistory() -> SearchHistory {
        SearchHistory(cities: cities.map { $0.makeCity() })
    }
}

extension StoredSearchHistory.StoredCity {
    init(_ city: City) {
        id = city.id
        name = city.name
        region = city.region
        countryCode = city.countryCode
        latitude = city.coordinate.latitude
        longitude = city.coordinate.longitude
    }

    func makeCity() -> City {
        City(
            id: id,
            name: name,
            region: region,
            countryCode: countryCode,
            coordinate: Coordinate(latitude: latitude, longitude: longitude)
        )
    }
}
