import Domain
import Foundation

extension City {
    static func stub(id: Int, name: String = "City") -> City {
        City(
            id: id,
            name: name,
            region: "Pomeranian Voivodeship",
            countryCode: "PL",
            coordinate: Coordinate(latitude: 54.35, longitude: 18.65),
            timeZone: TimeZone(identifier: "Europe/Warsaw")!
        )
    }
}
