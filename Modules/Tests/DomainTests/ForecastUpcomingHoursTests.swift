import Domain
import Foundation
import Testing

struct ForecastUpcomingHoursTests {
    @Test func startsWithCurrentHour() throws {
        let forecast = try Forecast.stub(timeZone: "Europe/Warsaw", firstHour: "2026-01-10T08:00:00Z", hours: 48)

        let hours = forecast.upcomingHours(from: try date("2026-01-10T12:45:00Z"))

        #expect(hours.first?.time == (try date("2026-01-10T12:00:00Z")))
        #expect(hours.count == 24)
    }

    @Test func returnsRemainingHoursNearEndOfForecast() throws {
        let forecast = try Forecast.stub(timeZone: "Europe/Warsaw", firstHour: "2026-01-10T08:00:00Z", hours: 5)

        #expect(forecast.upcomingHours(from: try date("2026-01-10T10:30:00Z")).count == 3)
        #expect(forecast.upcomingHours(from: try date("2026-01-11T08:00:00Z")).isEmpty)
    }

    @Test func countsHoursInLocationTimeZone() throws {
        let forecast = try Forecast.stub(timeZone: "Asia/Kolkata", firstHour: "2026-01-10T06:30:00Z", hours: 24)

        let hours = forecast.upcomingHours(from: try date("2026-01-10T10:10:00Z"))

        #expect(hours.first?.time == (try date("2026-01-10T09:30:00Z")))
    }
}

private func date(_ iso8601: String) throws -> Date {
    try Date(iso8601, strategy: .iso8601)
}

private extension Forecast {
    static func stub(timeZone identifier: String, firstHour: String, hours: Int) throws -> Forecast {
        let start = try date(firstHour)
        let celsius = Measurement(value: 0, unit: UnitTemperature.celsius)
        let hourly = (0..<hours).map { offset in
            HourlyForecast(
                time: start.addingTimeInterval(Double(offset) * 3600),
                temperature: celsius,
                precipitationProbability: 0,
                condition: .clear,
                isDay: true,
                cape: 0,
                liftedIndex: 0
            )
        }
        let current = CurrentConditions(
            temperature: celsius,
            apparentTemperature: celsius,
            precipitationProbability: 0,
            relativeHumidity: 0,
            visibility: Measurement(value: 10, unit: .kilometers),
            uvIndex: 0,
            wind: Wind(
                speed: Measurement(value: 0, unit: .kilometersPerHour),
                gusts: Measurement(value: 0, unit: .kilometersPerHour),
                direction: Measurement(value: 0, unit: .degrees)
            ),
            condition: .clear,
            isDay: true
        )
        return Forecast(
            timeZone: try #require(TimeZone(identifier: identifier)),
            current: current,
            hourly: hourly,
            daily: []
        )
    }
}
