import SwiftUI

struct UVIndexBar: View {
    private static let scaleMaximum = 11.0
    private static let markerSize: CGFloat = 9

    let index: Double

    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        GeometryReader { geometry in
            let position = min(max(index.rounded() / Self.scaleMaximum, 0), 1)
            Capsule()
                .fill(redactionReasons.isEmpty ? AnyShapeStyle(Self.gradient) : AnyShapeStyle(.fill.tertiary))
                .overlay(alignment: .leading) {
                    Circle()
                        .fill(.white)
                        .stroke(.black.opacity(0.3), lineWidth: 1)
                        .frame(width: Self.markerSize, height: Self.markerSize)
                        .offset(x: position * (geometry.size.width - Self.markerSize))
                }
        }
        .frame(height: 5)
    }

    private static let gradient = LinearGradient(
        colors: [.green, .yellow, .orange, .red, .purple],
        startPoint: .leading,
        endPoint: .trailing
    )
}
