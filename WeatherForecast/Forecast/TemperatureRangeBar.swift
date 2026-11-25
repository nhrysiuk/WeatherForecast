import SwiftUI

struct TemperatureRangeBar: View {
    let range: ClosedRange<Double>
    let scale: ClosedRange<Double>

    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let span = max(scale.upperBound - scale.lowerBound, 1)
            let start = (range.lowerBound - scale.lowerBound) / span * width
            let end = (range.upperBound - scale.lowerBound) / span * width
            Capsule()
                .fill(.fill.tertiary)
                .overlay {
                    LinearGradient(
                        colors: redactionReasons.isEmpty ? [.cyan, .yellow, .orange] : [.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(alignment: .leading) {
                        Capsule()
                            .frame(width: max(end - start, 4))
                            .offset(x: start)
                    }
                }
        }
        .frame(height: 5)
    }
}
