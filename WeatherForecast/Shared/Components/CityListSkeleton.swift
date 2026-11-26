import Domain
import SwiftUI

struct CityListSkeleton: View {
    private static let rowCount = 6
    private static let placeholder = City(
        id: 0,
        name: "Placeholder",
        region: "Placeholder region",
        countryCode: nil,
        coordinate: Coordinate(latitude: 0, longitude: 0)
    )

    var body: some View {
        List(0..<Self.rowCount, id: \.self) { _ in
            CityRow(city: Self.placeholder)
        }
        .skeleton(true)
    }
}
