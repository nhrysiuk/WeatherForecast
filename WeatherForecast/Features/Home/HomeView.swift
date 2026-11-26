import Domain
import SwiftUI

struct HomeView: View {
    private struct SearchRequest: Equatable {
        let query: String
        let attempt: Int
    }

    private let dependencies: AppDependencies
    @Bindable private var router: AppRouter
    @State private var search: SearchViewModel
    @State private var query = ""
    @State private var searchAttempt = 0

    init(dependencies: AppDependencies, router: AppRouter) {
        self.dependencies = dependencies
        self.router = router
        _search = State(initialValue: SearchViewModel(citySearch: dependencies.citySearch))
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            content
        }
    }

    private var content: some View {
        HomeContent(
            query: query,
            search: search,
            historyStore: dependencies.historyStore,
            open: router.open,
            retrySearch: { searchAttempt += 1 }
        )
            .navigationTitle(Text(.homeTitle))
            .searchable(text: $query, prompt: Text(.searchPrompt))
            .keepsNavigationBarWhileSearching()
            .toolbar {
                if #available(iOS 26, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .forecast(let city):
                    ForecastView(city: city, forecastProvider: dependencies.forecastProvider)
                }
            }
            .task {
                await dependencies.historyStore.load()
            }
            .task(id: SearchRequest(query: query, attempt: searchAttempt)) {
                await search.search(for: query)
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
    let query: String
    let search: SearchViewModel
    let historyStore: HistoryStore
    let open: (City) -> Void
    let retrySearch: () -> Void

    @Environment(\.isSearching) private var isSearching

    var body: some View {
        List {
            if isSearching {
                SearchResultsView(search: search, open: open)
            } else {
                SearchHistoryView(historyStore: historyStore, open: open)
            }
        }
        .overlay {
            if isSearching {
                SearchMessageView(query: query, search: search, retry: retrySearch)
            } else if historyStore.isLoaded && !hasHistory {
                ContentUnavailableView {
                    Label(.findCityTitle, systemImage: "magnifyingglass")
                } description: {
                    Text(.findCityMessage)
                }
            }
        }
        .toolbar {
            if !isSearching && hasHistory {
                EditButton()
            }
        }
    }

    private var hasHistory: Bool {
        !historyStore.history.cities.isEmpty
    }
}
