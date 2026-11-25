import Domain
import SwiftUI

struct CityListSkeleton: View {
    private static let rowCount = 6
    private static let placeholder = City(
        id: 0,
        name: "Placeholder",
        region: "Placeholder region",
        countryCode: nil,
        coordinate: Coordinate(latitude: 0, longitude: 0),
        timeZone: .gmt
    )

    var showsWeather = false

    var body: some View {
        List(0..<Self.rowCount, id: \.self) { _ in
            if showsWeather {
                HistoryRow(city: Self.placeholder, summary: WeatherSummaryView.placeholder, showsSkeleton: true)
            } else {
                CityRow(city: Self.placeholder)
            }
        }
        .skeleton(true)
    }
}
