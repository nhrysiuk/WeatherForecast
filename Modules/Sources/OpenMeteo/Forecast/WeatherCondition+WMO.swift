import Domain

extension WeatherCondition {
    init(wmoCode: Int) {
        switch wmoCode {
        case 0:
            self = .clear
        case 1, 2:
            self = .partlyCloudy
        case 3:
            self = .overcast
        case 45, 48:
            self = .fog
        case 51, 53, 55:
            self = .drizzle
        case 56, 57, 66, 67:
            self = .freezingRain
        case 61, 63, 65:
            self = .rain
        case 71, 73, 75, 77, 85, 86:
            self = .snow
        case 80, 81, 82:
            self = .showers
        case 95, 96, 99:
            self = .thunderstorm
        default:
            self = .unknown
        }
    }
}
