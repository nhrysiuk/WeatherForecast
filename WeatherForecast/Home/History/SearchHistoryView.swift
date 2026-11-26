import Domain
import SwiftUI

struct SearchHistoryView: View {
    let viewModel: HomeViewModel
    let open: (City) -> Void

    var body: some View {
        switch viewModel.historyState {
        case .loading:
            CityListSkeleton(showsWeather: true)
        case .loaded:
            List {
                Section {
                    ForEach(viewModel.history.cities) { city in
                        CityLink(city: city, open: open) {
                            HistoryRow(
                                city: city,
                                summary: viewModel.summaries[city.coordinate],
                                showsSkeleton: !viewModel.summariesFailed
                            )
                        }
                    }
                    .onDelete { offsets in
                        Task { await viewModel.remove(atOffsets: offsets) }
                    }
                } header: {
                    Text(.recentSearchesHeader)
                }
            }
            .task(id: viewModel.history.cities.map(\.coordinate)) {
                await viewModel.loadSummaries()
            }
        }
    }
}
