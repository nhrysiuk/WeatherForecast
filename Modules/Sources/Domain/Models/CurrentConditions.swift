import Foundation

public struct CurrentConditions: Equatable, Sendable {
    public let temperature: Measurement<UnitTemperature>
    public let apparentTemperature: Measurement<UnitTemperature>
    public let cloudCover: Int
    public let precipitationProbability: Int
    public let relativeHumidity: Int
    public let pressure: Measurement<UnitPressure>
    public let visibility: Measurement<UnitLength>
    public let uvIndex: Double?
    public let wind: Wind
    public let condition: WeatherCondition
    public let isDay: Bool

    public init(
        temperature: Measurement<UnitTemperature>,
        apparentTemperature: Measurement<UnitTemperature>,
        cloudCover: Int,
        precipitationProbability: Int,
        relativeHumidity: Int,
        pressure: Measurement<UnitPressure>,
        visibility: Measurement<UnitLength>,
        uvIndex: Double?,
        wind: Wind,
        condition: WeatherCondition,
        isDay: Bool
    ) {
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.cloudCover = cloudCover
        self.precipitationProbability = precipitationProbability
        self.relativeHumidity = relativeHumidity
        self.pressure = pressure
        self.visibility = visibility
        self.uvIndex = uvIndex
        self.wind = wind
        self.condition = condition
        self.isDay = isDay
    }
}
