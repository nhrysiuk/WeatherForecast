import Domain
import Foundation

struct GeocodingResponse: Decodable {
    struct Place: Decodable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        let timezone: String?
        let countryCode: String?
        let region: String?
        let featureCode: String?

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case latitude
            case longitude
            case timezone
            case countryCode = "country_code"
            case region = "admin1"
            case featureCode = "feature_code"
        }
    }

    let results: [Place]?
}

extension GeocodingResponse.Place {
    private static let formerSettlementCodes: Set<String> = ["PPLCH", "PPLH", "PPLQ", "PPLW"]

    var city: City? {
        guard isInhabitedPlace, let timezone, let timeZone = TimeZone(identifier: timezone) else {
            return nil
        }
        return City(
            id: id,
            name: name,
            region: region,
            countryCode: countryCode,
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            timeZone: timeZone
        )
    }

    private var isInhabitedPlace: Bool {
        guard let featureCode else {
            return true
        }
        let isPopulatedPlace = featureCode.hasPrefix("PPL") || featureCode == "STLMT"
        return isPopulatedPlace && !Self.formerSettlementCodes.contains(featureCode)
    }
}
