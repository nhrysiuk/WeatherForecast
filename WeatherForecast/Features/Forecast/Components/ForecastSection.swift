import SwiftUI

struct ForecastSection<Content: View>: View {
    let title: LocalizedStringResource
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.fill.quaternary, in: .rect(cornerRadius: 16))
    }
}
