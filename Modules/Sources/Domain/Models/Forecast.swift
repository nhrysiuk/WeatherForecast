import Foundation

/// Conditions at the moment the forecast was issued.
public struct CurrentConditions: Hashable, Sendable {
    public let time: Date
    public let temperature: Measurement<UnitTemperature>
    /// Share of the sky covered by clouds, 0...100.
    public let cloudCover: Int
    /// Chance of precipitation, 0...100.
    public let precipitationProbability: Int
    public let condition: WeatherCondition

    public init(
        time: Date,
        temperature: Measurement<UnitTemperature>,
        cloudCover: Int,
        precipitationProbability: Int,
        condition: WeatherCondition
    ) {
        self.time = time
        self.temperature = temperature
        self.cloudCover = cloudCover
        self.precipitationProbability = precipitationProbability
        self.condition = condition
    }
}

/// One hour of the hourly forecast.
public struct HourlyForecast: Hashable, Sendable {
    /// Start of the hour, as an absolute point in time.
    public let time: Date
    public let temperature: Measurement<UnitTemperature>
    public let condition: WeatherCondition

    public init(
        time: Date,
        temperature: Measurement<UnitTemperature>,
        condition: WeatherCondition
    ) {
        self.time = time
        self.temperature = temperature
        self.condition = condition
    }
}

/// Weather for one place, expressed in that place's time zone.
public struct Forecast: Hashable, Sendable {
    /// Time zone of the forecast location, not of the device.
    /// Use it whenever hours are shown or grouped.
    public let timeZone: TimeZone
    public let current: CurrentConditions
    /// Consecutive hours in ascending order.
    public let hourly: [HourlyForecast]

    public init(timeZone: TimeZone, current: CurrentConditions, hourly: [HourlyForecast]) {
        self.timeZone = timeZone
        self.current = current
        self.hourly = hourly
    }
}
