import Domain
import Foundation

extension City {
    static func stub(id: Int, name: String = "City") -> City {
        City(
            id: id,
            name: name,
            region: "Masovian Voivodeship",
            countryCode: "PL",
            coordinate: Coordinate(latitude: 52.23, longitude: 21.01),
            timeZone: TimeZone(identifier: "Europe/Warsaw")!
        )
    }
}
