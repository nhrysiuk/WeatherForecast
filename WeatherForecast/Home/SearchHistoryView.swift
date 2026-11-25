import Domain
import SwiftUI

struct SearchHistoryView: View {
    let model: HomeModel

    var body: some View {
        switch model.historyState {
        case .loading:
            CityListSkeleton(showsWeather: true)
        case .failed:
            ErrorStateView(.unavailable) {
                Task { await model.loadHistory() }
            }
        case .loaded:
            List {
                Section {
                    ForEach(model.history.cities) { city in
                        HistoryRow(
                            city: city,
                            summary: model.summaries[city.coordinate],
                            showsSkeleton: !model.summariesFailed
                        )
                    }
                    .onDelete { offsets in
                        Task { await model.remove(atOffsets: offsets) }
                    }
                } header: {
                    Text(.recentSearchesHeader)
                }
            }
            .task(id: model.history.cities.map(\.coordinate)) {
                await model.loadSummaries()
            }
        }
    }
}
