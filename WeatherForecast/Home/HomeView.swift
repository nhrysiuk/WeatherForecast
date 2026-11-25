import Domain
import SwiftUI

struct HomeView: View {
    private struct SearchRequest: Equatable {
        let query: String
        let attempt: Int
    }

    @Bindable private var model: HomeModel
    @State private var searchAttempt = 0

    init(model: HomeModel) {
        self.model = model
    }

    var body: some View {
        HomeContent(model: model, retrySearch: { searchAttempt += 1 })
            .navigationTitle(Text(.homeTitle))
            .searchable(text: $model.query, prompt: Text(.searchPrompt))
            .keepsNavigationBarWhileSearching()
            .toolbar {
                if #available(iOS 26, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                }
            }
            .navigationDestination(for: City.self) { city in
                ForecastView(city: city, forecastProvider: model.forecastProvider)
            }
            .task {
                await model.loadHistory()
            }
            .task(id: SearchRequest(query: model.query, attempt: searchAttempt)) {
                await model.search()
            }
    }
}

private extension View {
    @ViewBuilder
    func keepsNavigationBarWhileSearching() -> some View {
        if #available(iOS 17.1, *) {
            searchPresentationToolbarBehavior(.avoidHidingContent)
        } else {
            self
        }
    }
}

private struct HomeContent: View {
    let model: HomeModel
    let retrySearch: () -> Void

    @Environment(\.isSearching) private var isSearching

    var body: some View {
        if showsPlaceholder {
            List {}
                .overlay {
                    ContentUnavailableView {
                        Label(.findCityTitle, systemImage: "magnifyingglass")
                    } description: {
                        Text(.findCityMessage)
                    }
                }
        } else {
            SearchView(model: model, retry: retrySearch)
        }
    }

    private var showsPlaceholder: Bool {
        let hasNoHistory = model.historyState == .loaded && model.history.cities.isEmpty
        return !isSearching || (model.searchState == .idle && hasNoHistory)
    }
}
