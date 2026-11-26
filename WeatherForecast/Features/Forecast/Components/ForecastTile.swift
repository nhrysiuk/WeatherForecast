import SwiftUI

struct ForecastTile<Content: View>: View {
    let title: LocalizedStringResource
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        ForecastSection(title: title, systemImage: systemImage) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxHeight: .infinity)
    }
}
