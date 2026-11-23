import Domain

extension City {
    static func stub(id: Int, name: String = "City") -> City {
        City(
            id: id,
            name: name,
            region: nil,
            country: "Poland",
            coordinate: Coordinate(latitude: 52.23, longitude: 21.01)
        )
    }
}
