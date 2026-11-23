/// What the sky is doing, independent of any provider's encoding.
public enum WeatherCondition: Hashable, Codable, Sendable {
    case clear
    case partlyCloudy
    case overcast
    case fog
    case drizzle
    case rain
    case freezingRain
    case snow
    case showers
    case thunderstorm
    case unknown
}
