import Domain
import SwiftUI

struct SearchHistoryView: View {
    let historyStore: HistoryStore
    let open: (City) -> Void

    var body: some View {
        if !historyStore.isLoaded {
            CityRowsSkeleton()
        } else if !historyStore.history.cities.isEmpty {
            Section {
                ForEach(historyStore.history.cities) { city in
                    CityLink(city: city, open: open) {
                        CityRow(city: city)
                    }
                }
                .onDelete { offsets in
                    historyStore.remove(atOffsets: offsets)
                }
            } header: {
                Text(.recentSearchesHeader)
            }
        }
    }
}
