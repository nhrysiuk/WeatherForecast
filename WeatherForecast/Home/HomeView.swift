import Domain
import SwiftUI

struct HomeView: View {
    private struct SearchRequest: Equatable {
        let query: String
        let attempt: Int
    }

    @Bindable private var viewModel: HomeViewModel
    @State private var searchAttempt = 0
    @State private var path: [City] = []

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
        }
    }

    private var content: some View {
        HomeContent(
            viewModel: viewModel,
            open: { path.append($0) },
            retrySearch: { searchAttempt += 1 }
        )
            .navigationTitle(Text(.homeTitle))
            .searchable(text: $viewModel.query, prompt: Text(.searchPrompt))
            .keepsNavigationBarWhileSearching()
            .toolbar {
                if #available(iOS 26, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                }
            }
            .navigationDestination(for: City.self) { city in
                ForecastView(city: city, forecastProvider: viewModel.forecastProvider)
                    .task { await viewModel.save(city) }
            }
            .task {
                await viewModel.loadHistory()
            }
            .task(id: SearchRequest(query: viewModel.query, attempt: searchAttempt)) {
                await viewModel.search()
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
    let viewModel: HomeViewModel
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
            SearchView(viewModel: viewModel, open: open, retry: retrySearch)
        } else {
            SearchHistoryView(viewModel: viewModel, open: open)
                .toolbar {
                    if viewModel.historyState == .loaded {
                        EditButton()
                    }
                }
        }
    }

    private var showsPlaceholder: Bool {
        let hasNoHistory = viewModel.historyState == .loaded && viewModel.history.cities.isEmpty
        return hasNoHistory && (!isSearching || viewModel.searchState == .idle)
    }
}
