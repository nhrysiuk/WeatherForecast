import Domain

extension City {
    nonisolated static func stub(
        id: Int,
        name: String = "City",
        coordinate: Coordinate = Coordinate(latitude: 54.35, longitude: 18.65)
    ) -> City {
        City(
            id: id,
            name: name,
            region: "Pomeranian Voivodeship",
            countryCode: "PL",
            coordinate: coordinate
        )
    }
}
