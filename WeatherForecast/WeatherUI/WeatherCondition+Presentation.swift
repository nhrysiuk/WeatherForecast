import Domain
import Foundation

extension WeatherCondition {
    func symbolName(isDay: Bool) -> String {
        switch self {
        case .clear:
            isDay ? "sun.max.fill" : "moon.stars.fill"
        case .partlyCloudy:
            isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case .overcast:
            "cloud.fill"
        case .fog:
            "cloud.fog.fill"
        case .drizzle:
            "cloud.drizzle.fill"
        case .rain:
            "cloud.rain.fill"
        case .freezingRain:
            "cloud.sleet.fill"
        case .snow:
            "cloud.snow.fill"
        case .showers:
            isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case .thunderstorm:
            "cloud.bolt.rain.fill"
        case .unknown:
            "thermometer.medium"
        }
    }

    var localizedName: LocalizedStringResource {
        switch self {
        case .clear:
            .conditionClear
        case .partlyCloudy:
            .conditionPartlyCloudy
        case .overcast:
            .conditionOvercast
        case .fog:
            .conditionFog
        case .drizzle:
            .conditionDrizzle
        case .rain:
            .conditionRain
        case .freezingRain:
            .conditionFreezingRain
        case .snow:
            .conditionSnow
        case .showers:
            .conditionShowers
        case .thunderstorm:
            .conditionThunderstorm
        case .unknown:
            .conditionUnknown
        }
    }
}
