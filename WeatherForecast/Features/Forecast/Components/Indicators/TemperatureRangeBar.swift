import SwiftUI

struct TemperatureRangeBar: View {
    private static let minimumWidth: CGFloat = 5

    let range: ClosedRange<Double>
    let scale: ClosedRange<Double>

    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let span = max(scale.upperBound - scale.lowerBound, 1)
            let start = (range.lowerBound - scale.lowerBound) / span * width
            let end = (range.upperBound - scale.lowerBound) / span * width
            let barWidth = max(end - start, Self.minimumWidth)
            Capsule()
                .fill(.fill.tertiary)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(fill)
                        .frame(width: barWidth)
                        .offset(x: min(start, width - barWidth))
                }
        }
        .frame(height: 6)
    }

    private var fill: AnyShapeStyle {
        guard redactionReasons.isEmpty else {
            return AnyShapeStyle(.clear)
        }
        return AnyShapeStyle(LinearGradient(
            gradient: TemperatureColorScale.gradient(for: range),
            startPoint: .leading,
            endPoint: .trailing
        ))
    }
}
