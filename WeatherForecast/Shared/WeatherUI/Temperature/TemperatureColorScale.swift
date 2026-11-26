import SwiftUI

enum TemperatureColorScale {
    struct RGB: Equatable {
        let red: Double
        let green: Double
        let blue: Double

        var color: Color {
            Color(red: red, green: green, blue: blue)
        }

        fileprivate func mixed(with other: RGB, fraction: Double) -> RGB {
            RGB(
                red: red + (other.red - red) * fraction,
                green: green + (other.green - green) * fraction,
                blue: blue + (other.blue - blue) * fraction
            )
        }
    }

    struct Stop: Equatable {
        let rgb: RGB
        let location: Double
    }

    static let anchors: [(celsius: Double, rgb: RGB)] = [
        (-30, RGB(red: 0.55, green: 0.25, blue: 0.85)),
        (-20, RGB(red: 0.42, green: 0.32, blue: 0.95)),
        (-10, RGB(red: 0.28, green: 0.45, blue: 1.00)),
        (0, RGB(red: 0.20, green: 0.62, blue: 1.00)),
        (10, RGB(red: 0.18, green: 0.80, blue: 0.72)),
        (20, RGB(red: 0.98, green: 0.80, blue: 0.18)),
        (30, RGB(red: 1.00, green: 0.52, blue: 0.14)),
        (40, RGB(red: 0.93, green: 0.18, blue: 0.20)),
    ]

    static func rgb(celsius: Double) -> RGB {
        guard let first = anchors.first, let last = anchors.last else {
            return RGB(red: 0, green: 0, blue: 0)
        }
        if celsius <= first.celsius {
            return first.rgb
        }
        if celsius >= last.celsius {
            return last.rgb
        }
        let upperIndex = anchors.firstIndex { $0.celsius >= celsius } ?? anchors.endIndex - 1
        let lower = anchors[upperIndex - 1]
        let upper = anchors[upperIndex]
        let fraction = (celsius - lower.celsius) / (upper.celsius - lower.celsius)
        return lower.rgb.mixed(with: upper.rgb, fraction: fraction)
    }

    static func stops(for range: ClosedRange<Double>) -> [Stop] {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else {
            let rgb = rgb(celsius: range.lowerBound)
            return [Stop(rgb: rgb, location: 0), Stop(rgb: rgb, location: 1)]
        }
        let inner = anchors
            .map(\.celsius)
            .filter { $0 > range.lowerBound && $0 < range.upperBound }
        return ([range.lowerBound] + inner + [range.upperBound]).map { celsius in
            Stop(rgb: rgb(celsius: celsius), location: (celsius - range.lowerBound) / span)
        }
    }

    static func gradient(for range: ClosedRange<Double>) -> Gradient {
        Gradient(stops: stops(for: range).map { Gradient.Stop(color: $0.rgb.color, location: $0.location) })
    }
}
