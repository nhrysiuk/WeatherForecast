import Foundation

public struct Forecast: Equatable, Sendable {
    public let timeZone: TimeZone
    public let current: CurrentConditions
    public let hourly: [HourlyForecast]
    public let daily: [DailyForecast]

    public init(
        timeZone: TimeZone,
        current: CurrentConditions,
        hourly: [HourlyForecast],
        daily: [DailyForecast]
    ) {
        self.timeZone = timeZone
        self.current = current
        self.hourly = hourly
        self.daily = daily
    }
}
