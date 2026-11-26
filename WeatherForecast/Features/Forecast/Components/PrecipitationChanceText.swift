import SwiftUI

struct PrecipitationChanceText: View {
    private static let shownProbability = 20

    let probability: Int

    static func isShown(_ probability: Int) -> Bool {
        probability >= shownProbability
    }

    var body: some View {
        if Self.isShown(probability) {
            Text(Double(probability) / 100, format: .percent)
                .foregroundStyle(.blue)
        }
    }
}
