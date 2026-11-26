import Domain
import SwiftUI

struct WeatherSymbol: View {
    let condition: WeatherCondition
    let isDay: Bool

    var body: some View {
        let colors = condition.symbolColors(isDay: isDay)
        Image(systemName: condition.symbolName(isDay: isDay))
            .symbolRenderingMode(.palette)
            .foregroundStyle(colors.primary, colors.secondary, colors.tertiary)
    }
}

private extension Color {
    static let sun = Color.adaptive(light: 0xF5A300, dark: 0xFFD23F)
    static let cloud = Color.adaptive(light: 0x7D8A99, dark: 0xE8EDF2)
    static let moon = Color.adaptive(light: 0x5A63C8, dark: 0xF2EDC4)
    static let raindrop = Color.adaptive(light: 0x2F80ED, dark: 0x5CB8FF)
    static let snowflake = Color.adaptive(light: 0x4AA3DF, dark: 0xBFE6FF)
    static let bolt = Color.adaptive(light: 0xF29900, dark: 0xFFC233)
}

private extension WeatherCondition {
    struct SymbolColors {
        let primary: Color
        let secondary: Color
        let tertiary: Color
    }

    func symbolColors(isDay: Bool) -> SymbolColors {
        let celestial: Color = isDay ? .sun : .moon
        switch self {
        case .clear:
            return SymbolColors(primary: celestial, secondary: celestial, tertiary: celestial)
        case .partlyCloudy:
            return SymbolColors(primary: .cloud, secondary: celestial, tertiary: celestial)
        case .overcast, .fog:
            return SymbolColors(primary: .cloud, secondary: .cloud, tertiary: .cloud)
        case .drizzle, .rain:
            return SymbolColors(primary: .cloud, secondary: .raindrop, tertiary: .raindrop)
        case .freezingRain, .snow:
            return SymbolColors(primary: .cloud, secondary: .snowflake, tertiary: .snowflake)
        case .showers:
            return SymbolColors(primary: .cloud, secondary: celestial, tertiary: .raindrop)
        case .thunderstorm:
            return SymbolColors(primary: .cloud, secondary: .bolt, tertiary: .raindrop)
        case .unknown:
            return SymbolColors(primary: .secondary, secondary: .secondary, tertiary: .secondary)
        }
    }
}
