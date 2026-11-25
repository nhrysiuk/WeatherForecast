import DesignSystem
import Domain
import SwiftUI

struct SearchView: View {
    let model: HomeModel
    let retry: () -> Void

    @Environment(\.dismissSearch) private var dismissSearch

    var body: some View {
        switch model.searchState {
        case .idle:
            SearchHistoryView(model: model)
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
            if model.isHistoryFull {
                Section {
                    Label(.historyFullMessage, systemImage: "exclamationmark.circle")
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                ForEach(cities) { city in
                    Button {
                        select(city)
                    } label: {
                        CityRow(city: city)
                    }
                    .tint(.primary)
                }
            }
        }
    }

    private func select(_ city: City) {
        Task { await model.save(city) }
        dismissSearch()
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

private extension ErrorStateView.Reason {
    init(_ error: WeatherError) {
        switch error {
        case .offline:
            self = .offline
        case .server:
            self = .unavailable
        }
    }
}
