import SwiftUI

enum TemperatureScale: String, CaseIterable, Identifiable {
    case celsius
    case fahrenheit

    static let storageKey = "temperatureScale"

    init(locale: Locale) {
        let unit = UnitTemperature(forLocale: locale, usage: .weather)
        self = unit.symbol == UnitTemperature.fahrenheit.symbol ? .fahrenheit : .celsius
    }

    var id: Self { self }

    var unit: UnitTemperature {
        switch self {
        case .celsius: .celsius
        case .fahrenheit: .fahrenheit
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .celsius: .celsius
        case .fahrenheit: .fahrenheit
        }
    }
}

extension EnvironmentValues {
    @Entry var temperatureScale = TemperatureScale(locale: .autoupdatingCurrent)
}
