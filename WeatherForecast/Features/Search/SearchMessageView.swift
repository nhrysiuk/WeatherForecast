import Domain
import SwiftUI

struct SearchMessageView: View {
    let query: String
    let search: SearchViewModel
    let retry: () -> Void

    var body: some View {
        switch search.state {
        case .idle where hasTypedText:
            Text(.searchMinimumLettersHint)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        case .invalid(let error):
            ContentUnavailableView {
                Label(.invalidNameTitle, systemImage: "character.cursor.ibeam")
            } description: {
                Text(error.message)
            }
        case .results(let cities) where cities.isEmpty:
            ContentUnavailableView.search(text: query)
        case .failed(let error):
            ErrorStateView(reason: .init(error), retry: retry)
        case .idle, .loading, .results:
            EmptyView()
        }
    }

    private var hasTypedText: Bool {
        query.contains { !$0.isWhitespace }
    }
}

private extension CityNameValidationError {
    var message: LocalizedStringResource {
        switch self {
        case .containsDigits:
            .invalidNameDigits
        case .containsDisallowedCharacters:
            .invalidNameCharacters
        }
    }
}
