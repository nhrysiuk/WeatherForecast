import Foundation

public struct Coordinate: Hashable, Codable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct City: Identifiable, Hashable, Codable, Sendable {
    public let id: Int
    public let name: String
    public let region: String?
    public let countryCode: String?
    public let coordinate: Coordinate
    public let timeZone: TimeZone

    public init(
        id: Int,
        name: String,
        region: String?,
        countryCode: String?,
        coordinate: Coordinate,
        timeZone: TimeZone
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.countryCode = countryCode
        self.coordinate = coordinate
        self.timeZone = timeZone
    }
}
