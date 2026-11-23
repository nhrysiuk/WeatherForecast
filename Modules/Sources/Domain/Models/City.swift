import Foundation

/// A geographic point in WGS84 degrees.
public struct Coordinate: Hashable, Codable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// A city returned by search and remembered in the search history.
public struct City: Identifiable, Hashable, Codable, Sendable {
    /// Stable identifier assigned by the geocoding provider.
    public let id: Int
    public let name: String
    /// Region or province, e.g. "Masovian Voivodeship".
    public let region: String?
    public let country: String?
    public let coordinate: Coordinate

    public init(
        id: Int,
        name: String,
        region: String?,
        country: String?,
        coordinate: Coordinate
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.coordinate = coordinate
    }
}
