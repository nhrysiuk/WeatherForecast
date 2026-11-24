import Foundation

public struct HourlyForecast: Equatable, Sendable {
    public let time: Date
    public let temperature: Measurement<UnitTemperature>
    public let precipitationProbability: Int
    public let condition: WeatherCondition
    public let isDay: Bool
    public let cape: Double
    public let liftedIndex: Double

    public init(
        time: Date,
        temperature: Measurement<UnitTemperature>,
        precipitationProbability: Int,
        condition: WeatherCondition,
        isDay: Bool,
        cape: Double,
        liftedIndex: Double
    ) {
        self.time = time
        self.temperature = temperature
        self.precipitationProbability = precipitationProbability
        self.condition = condition
        self.isDay = isDay
        self.cape = cape
        self.liftedIndex = liftedIndex
    }
}
