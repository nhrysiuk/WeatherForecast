import Domain
import SwiftUI

struct HomeView: View {
    private struct SearchRequest: Equatable {
        let query: String
        let attempt: Int
    }

    @Bindable private var model: HomeModel
    @State private var searchAttempt = 0
    @State private var path: [City] = []

    init(model: HomeModel) {
        self.model = model
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
        }
    }

    private var content: some View {
        HomeContent(
            model: model,
            open: { path.append($0) },
            retrySearch: { searchAttempt += 1 }
        )
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
                    .task { await model.save(city) }
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
    let open: (City) -> Void
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
        } else if isSearching {
            SearchView(model: model, open: open, retry: retrySearch)
        } else {
            SearchHistoryView(model: model, open: open)
                .toolbar {
                    if model.historyState == .loaded {
                        EditButton()
                    }
                }
        }
    }

    private var showsPlaceholder: Bool {
        let hasNoHistory = model.historyState == .loaded && model.history.cities.isEmpty
        return hasNoHistory && (!isSearching || model.searchState == .idle)
    }
}
