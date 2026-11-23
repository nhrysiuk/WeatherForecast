import Domain
import Foundation
import Testing

struct ForecastUpcomingHoursTests {
    @Test func startsWithCurrentHour() throws {
        let forecast = try Forecast.stub(timeZone: "Europe/Warsaw", firstHour: "2026-01-10T08:00:00Z", hours: 48)

        let hours = forecast.upcomingHours(from: try date("2026-01-10T12:45:00Z"))

        #expect(hours.first?.time == (try date("2026-01-10T12:00:00Z")))
    }

    @Test func returnsAtMostLimit() throws {
        let forecast = try Forecast.stub(timeZone: "Europe/Warsaw", firstHour: "2026-01-10T08:00:00Z", hours: 48)

        let hours = forecast.upcomingHours(from: try date("2026-01-10T08:00:00Z"), limit: 24)

        #expect(hours.count == 24)
    }

    @Test func returnsRemainingHoursNearEndOfForecast() throws {
        let forecast = try Forecast.stub(timeZone: "Europe/Warsaw", firstHour: "2026-01-10T08:00:00Z", hours: 5)

        let hours = forecast.upcomingHours(from: try date("2026-01-10T10:30:00Z"))

        #expect(hours.count == 3)
    }

    @Test func isEmptyWhenForecastIsOutdated() throws {
        let forecast = try Forecast.stub(timeZone: "Europe/Warsaw", firstHour: "2026-01-10T08:00:00Z", hours: 5)

        #expect(forecast.upcomingHours(from: try date("2026-01-11T08:00:00Z")).isEmpty)
    }

    @Test func usesLocationTimeZoneForHalfHourOffsets() throws {
        // Kolkata is UTC+5:30, so its hours start at :30 UTC.
        let forecast = try Forecast.stub(timeZone: "Asia/Kolkata", firstHour: "2026-01-10T06:30:00Z", hours: 24)

        // 15:40 in Kolkata.
        let hours = forecast.upcomingHours(from: try date("2026-01-10T10:10:00Z"))

        // 15:00 in Kolkata. Counting hours in UTC would wrongly start at 10:30.
        #expect(hours.first?.time == (try date("2026-01-10T09:30:00Z")))
    }
}

private func date(_ iso8601: String) throws -> Date {
    try Date(iso8601, strategy: .iso8601)
}

private extension Forecast {
    static func stub(timeZone identifier: String, firstHour: String, hours: Int) throws -> Forecast {
        let timeZone = try #require(TimeZone(identifier: identifier))
        let start = try date(firstHour)
        let hourly = (0..<hours).map { offset in
            HourlyForecast(
                time: start.addingTimeInterval(Double(offset) * 3600),
                temperature: Measurement(value: Double(offset), unit: .celsius),
                condition: .clear
            )
        }
        let current = CurrentConditions(
            time: start,
            temperature: Measurement(value: 0, unit: .celsius),
            cloudCover: 0,
            precipitationProbability: 0,
            condition: .clear
        )
        return Forecast(timeZone: timeZone, current: current, hourly: hourly)
    }
}
