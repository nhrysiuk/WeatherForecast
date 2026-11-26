import SwiftUI

extension View {
    func skeleton(_ isActive: Bool) -> some View {
        redacted(reason: isActive ? .placeholder : [])
            .modifier(ShimmerModifier(isActive: isActive))
            .allowsHitTesting(!isActive)
    }
}

private struct ShimmerModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        if isActive {
            content.mask {
                ShimmerMask()
            }
        } else {
            content
        }
    }
}

private struct ShimmerMask: View {
    private static let bandWidth = 0.6
    private static let bandOpacity = 0.35
    private static let sweepDuration: TimeInterval = 1.5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            Rectangle()
        } else {
            TimelineView(.animation) { context in
                let bandStart = Self.bandStart(at: context.date)
                LinearGradient(
                    colors: [
                        .black,
                        .black.opacity(Self.bandOpacity),
                        .black,
                    ],
                    startPoint: UnitPoint(x: bandStart, y: 0.5),
                    endPoint: UnitPoint(x: bandStart + Self.bandWidth, y: 0.5)
                )
            }
        }
    }

    private static func bandStart(at date: Date) -> Double {
        let elapsed = date.timeIntervalSinceReferenceDate
            .truncatingRemainder(dividingBy: sweepDuration)
        let progress = elapsed / sweepDuration
        return -bandWidth + (1 + bandWidth) * progress
    }
}
