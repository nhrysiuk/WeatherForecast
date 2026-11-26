import SwiftUI

struct ForecastTile<Content: View>: View {
    let title: LocalizedStringResource
    let systemImage: String
    var tint: Color = .secondary
    @ViewBuilder let content: Content

    var body: some View {
        ForecastSection(title: title, systemImage: systemImage, tint: tint) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxHeight: .infinity)
    }
}
