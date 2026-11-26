import Foundation

extension Forecast {
    public func upcomingHours(from now: Date, limit: Int = 24) -> [HourlyForecast] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let currentHourStart = calendar.dateInterval(of: .hour, for: now)?.start ?? now

        return Array(
            hourly
                .drop { $0.time < currentHourStart }
                .prefix(limit)
        )
    }
}
