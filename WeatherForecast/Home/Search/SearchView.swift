import Domain
import SwiftUI

struct SearchView: View {
    let viewModel: HomeViewModel
    let open: (City) -> Void
    let retry: () -> Void

    var body: some View {
        switch viewModel.searchState {
        case .idle:
            SearchHistoryView(viewModel: viewModel, open: open)
        case .invalid(let error):
            ContentUnavailableView {
                Label(.invalidNameTitle, systemImage: "character.cursor.ibeam")
            } description: {
                Text(error.message)
            }
        case .loading:
            CityListSkeleton()
        case .results(let cities) where cities.isEmpty:
            ContentUnavailableView.search(text: viewModel.query)
        case .results(let cities):
            results(cities)
        case .failed(let error):
            ErrorStateView(reason: .init(error), retry: retry)
        }
    }

    private func results(_ cities: [City]) -> some View {
        List {
            ForEach(cities) { city in
                CityLink(city: city, open: open) {
                    CityRow(city: city)
                }
            }
        }
    }
}

private extension CityNameValidationError {
    var message: LocalizedStringResource {
        switch self {
        case .containsDigits:
            .invalidNameDigits
        case .containsDisallowedCharacters, .tooShort:
            .invalidNameCharacters
        }
    }
}
