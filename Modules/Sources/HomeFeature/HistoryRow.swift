import DesignSystem
import Domain
import SwiftUI

struct HistoryRow: View {
    let city: City
    let summary: WeatherSummary?
    let showsSkeleton: Bool

    var body: some View {
        HStack {
            CityRow(city: city)
            Spacer()
            if let summary {
                WeatherSummaryView(summary: summary)
            } else if showsSkeleton {
                WeatherSummaryView(summary: WeatherSummaryView.placeholder)
                    .skeleton(true)
            }
        }
    }
}
