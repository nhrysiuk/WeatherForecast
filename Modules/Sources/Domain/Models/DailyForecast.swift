import Foundation

public struct DailyForecast: Equatable, Sendable {
    public let date: Date
    public let minTemperature: Measurement<UnitTemperature>
    public let maxTemperature: Measurement<UnitTemperature>
    public let precipitationProbability: Int
    public let condition: WeatherCondition
    public let sunrise: Date?
    public let sunset: Date?
    public let moonPhase: Double

    public init(
        date: Date,
        minTemperature: Measurement<UnitTemperature>,
        maxTemperature: Measurement<UnitTemperature>,
        precipitationProbability: Int,
        condition: WeatherCondition,
        sunrise: Date?,
        sunset: Date?,
        moonPhase: Double
    ) {
        self.date = date
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.precipitationProbability = precipitationProbability
        self.condition = condition
        self.sunrise = sunrise
        self.sunset = sunset
        self.moonPhase = moonPhase
    }
}
