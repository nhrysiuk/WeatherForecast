import DesignSystem
import Domain
import SwiftUI

struct SearchHistoryView: View {
    let model: HomeModel

    var body: some View {
        switch model.historyState {
        case .loading:
            CityListSkeleton()
        case .failed:
            ErrorStateView(.unavailable) {
                Task { await model.loadHistory() }
            }
        case .loaded:
            List {
                Section {
                    ForEach(model.history.cities) { city in
                        CityRow(city: city)
                    }
                    .onDelete { offsets in
                        Task { await model.remove(atOffsets: offsets) }
                    }
                } header: {
                    Text(.recentSearchesHeader)
                }
            }
        }
    }
}
