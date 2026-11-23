import Foundation

extension Forecast {
    /// Hours starting with the current one, as seen at the forecast location.
    ///
    /// "Current hour" is computed in the location's time zone. That matters for
    /// zones with a non-whole-hour offset: at 15:40 in Kolkata (UTC+5:30) the
    /// current hour starts at 15:00 local time, which is 09:30 UTC, not 10:00.
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
