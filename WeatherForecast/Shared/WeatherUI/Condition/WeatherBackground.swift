import Domain
import SwiftUI

enum WeatherBackgroundStyle: Hashable {
    case neutral
    case clearDay
    case clearNight
    case cloudyDay
    case cloudyNight
    case overcast
    case fog
    case rain
    case snow
    case thunderstorm

    init(condition: WeatherCondition, isDay: Bool) {
        switch condition {
        case .clear:
            self = isDay ? .clearDay : .clearNight
        case .partlyCloudy:
            self = isDay ? .cloudyDay : .cloudyNight
        case .overcast:
            self = isDay ? .overcast : .cloudyNight
        case .fog:
            self = .fog
        case .drizzle, .rain, .freezingRain, .showers:
            self = .rain
        case .snow:
            self = .snow
        case .thunderstorm:
            self = .thunderstorm
        case .unknown:
            self = .neutral
        }
    }

    fileprivate var palette: Palette {
        switch self {
        case .neutral:
            Palette(light: [0x6FB1EE, 0xB5D8F7, 0xEAF4FC], dark: [0x0B1A30, 0x13294A, 0x1F3D66], glow: 0xFFFFFF, glowOpacity: 0.35)
        case .clearDay:
            Palette(light: [0x4FA8F0, 0xA3D6FF, 0xE4F3FF], dark: [0x0B3D7A, 0x1660A8, 0x2A7FC4], glow: 0xFFD66B, glowOpacity: 0.7)
        case .clearNight:
            Palette(light: [0x7880D6, 0xB1B6EE, 0xE4E5FA], dark: [0x070B24, 0x141B4D, 0x26306E], glow: 0xA8B4FF, glowOpacity: 0.35)
        case .cloudyDay:
            Palette(light: [0x78A3CC, 0xB5CCE2, 0xE7EEF5], dark: [0x1D3247, 0x2D4A66, 0x3E5F7E], glow: 0xFFE08A, glowOpacity: 0.45)
        case .cloudyNight:
            Palette(light: [0x868FAE, 0xBBC1D6, 0xE5E8F0], dark: [0x0E1422, 0x1C2538, 0x2B3650], glow: 0x9AA6D6, glowOpacity: 0.25)
        case .overcast:
            Palette(light: [0x93A0AD, 0xC3CBD3, 0xEBEEF1], dark: [0x1E2329, 0x2C333B, 0x3B444E], glow: 0xFFFFFF, glowOpacity: 0.3)
        case .fog:
            Palette(light: [0xACB2B8, 0xD1D4D8, 0xEEF0F1], dark: [0x202325, 0x2E3234, 0x3E4346], glow: 0xFFFFFF, glowOpacity: 0.35)
        case .rain:
            Palette(light: [0x5A7C9C, 0x90ACC8, 0xD2DEEA], dark: [0x101C2A, 0x1B2D42, 0x2A425C], glow: 0x7FD3FF, glowOpacity: 0.3)
        case .snow:
            Palette(light: [0x9EC3E6, 0xD0E3F4, 0xF5FAFF], dark: [0x1A2433, 0x2A3A50, 0x3F5470], glow: 0xFFFFFF, glowOpacity: 0.5)
        case .thunderstorm:
            Palette(light: [0x6B6693, 0x9C98BE, 0xD7D5E8], dark: [0x120F24, 0x231D40, 0x382F5C], glow: 0xC08CFF, glowOpacity: 0.35)
        }
    }
}

extension WeatherBackgroundStyle {
    init(forecast: Forecast) {
        self.init(condition: forecast.current.condition, isDay: forecast.current.isDay)
    }
}

private struct Palette {
    let light: [UInt32]
    let dark: [UInt32]
    let glow: UInt32
    let glowOpacity: Double
}

struct WeatherBackground: View {
    let style: WeatherBackgroundStyle

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            gradient
                .id(style)
                .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.8), value: style)
        .ignoresSafeArea()
    }

    private var gradient: some View {
        let palette = style.palette
        let colors = (colorScheme == .dark ? palette.dark : palette.light).map { Color(hex: $0) }
        let glowOpacity = colorScheme == .dark ? palette.glowOpacity * 0.5 : palette.glowOpacity
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
            .overlay {
                GeometryReader { geometry in
                    RadialGradient(
                        colors: [Color(hex: palette.glow, opacity: glowOpacity), .clear],
                        center: UnitPoint(x: 0.85, y: 0),
                        startRadius: 0,
                        endRadius: max(geometry.size.width, geometry.size.height) * 0.6
                    )
                }
            }
    }
}
