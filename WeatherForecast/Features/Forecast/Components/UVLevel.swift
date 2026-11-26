import Foundation

enum UVLevel {
    case low
    case moderate
    case high
    case veryHigh
    case extreme

    init(index: Double) {
        switch index.rounded() {
        case ..<3:
            self = .low
        case ..<6:
            self = .moderate
        case ..<8:
            self = .high
        case ..<11:
            self = .veryHigh
        default:
            self = .extreme
        }
    }

    var localizedName: LocalizedStringResource {
        switch self {
        case .low:
            .uvLow
        case .moderate:
            .uvModerate
        case .high:
            .uvHigh
        case .veryHigh:
            .uvVeryHigh
        case .extreme:
            .uvExtreme
        }
    }
}
