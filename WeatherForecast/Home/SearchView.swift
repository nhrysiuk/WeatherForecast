import Domain
import SwiftUI

struct SearchView: View {
    let model: HomeModel
    let open: (City) -> Void
    let retry: () -> Void

    var body: some View {
        switch model.searchState {
        case .idle:
            SearchHistoryView(model: model, open: open)
        case .invalid(let error):
            ContentUnavailableView {
                Label(.invalidNameTitle, systemImage: "character.cursor.ibeam")
            } description: {
                Text(error.message)
            }
        case .loading:
            CityListSkeleton()
        case .results(let cities) where cities.isEmpty:
            ContentUnavailableView.search(text: model.query)
        case .results(let cities):
            results(cities)
        case .failed(let error):
            ErrorStateView(ErrorStateView.Reason(error), retry: retry)
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
