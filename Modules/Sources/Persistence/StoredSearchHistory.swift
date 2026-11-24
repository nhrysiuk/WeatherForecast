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
        let timeZone: String
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

    func makeHistory() throws -> SearchHistory {
        SearchHistory(cities: try cities.map { try $0.makeCity() })
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
        timeZone = city.timeZone.identifier
    }

    func makeCity() throws -> City {
        guard let zone = TimeZone(identifier: timeZone) else {
            throw SearchHistoryStoreError.unknownTimeZone(timeZone)
        }
        return City(
            id: id,
            name: name,
            region: region,
            countryCode: countryCode,
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            timeZone: zone
        )
    }
}
