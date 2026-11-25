import Foundation

public struct WeatherSummary: Equatable, Sendable {
    public let temperature: Measurement<UnitTemperature>
    public let minTemperature: Measurement<UnitTemperature>
    public let maxTemperature: Measurement<UnitTemperature>
    public let condition: WeatherCondition
    public let isDay: Bool

    public init(
        temperature: Measurement<UnitTemperature>,
        minTemperature: Measurement<UnitTemperature>,
        maxTemperature: Measurement<UnitTemperature>,
        condition: WeatherCondition,
        isDay: Bool
    ) {
        self.temperature = temperature
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.condition = condition
        self.isDay = isDay
    }
}
