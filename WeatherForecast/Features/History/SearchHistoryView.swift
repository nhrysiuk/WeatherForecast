import Domain
import SwiftUI

struct SearchHistoryView: View {
    let history: HistoryViewModel
    let historyStore: HistoryStore
    let open: (City) -> Void

    var body: some View {
        if historyStore.isLoaded {
            List {
                Section {
                    ForEach(historyStore.history.cities) { city in
                        CityLink(city: city, open: open) {
                            HistoryRow(
                                city: city,
                                summary: history.summaries[city.coordinate],
                                showsSkeleton: !history.summariesFailed
                            )
                        }
                    }
                    .onDelete { offsets in
                        historyStore.remove(atOffsets: offsets)
                    }
                } header: {
                    Text(.recentSearchesHeader)
                }
            }
            .task(id: coordinates) {
                await history.loadSummaries(for: coordinates)
            }
        } else {
            CityListSkeleton(showsWeather: true)
        }
    }

    private var coordinates: [Coordinate] {
        historyStore.history.cities.map(\.coordinate)
    }
}
