import Domain
import Foundation

extension Forecast {
    nonisolated static func stub(temperature: Double = 3) -> Forecast {
        Forecast(
            timeZone: TimeZone(identifier: "Europe/Warsaw")!,
            current: CurrentConditions(
                temperature: Measurement(value: temperature, unit: .celsius),
                apparentTemperature: Measurement(value: temperature - 2, unit: .celsius),
                cloudCover: 90,
                precipitationProbability: 10,
                relativeHumidity: 80,
                pressure: Measurement(value: 1012, unit: .hectopascals),
                visibility: Measurement(value: 20, unit: .kilometers),
                uvIndex: 1,
                wind: Wind(
                    speed: Measurement(value: 12, unit: .kilometersPerHour),
                    gusts: Measurement(value: 25, unit: .kilometersPerHour),
                    direction: Measurement(value: 270, unit: .degrees)
                ),
                condition: .overcast,
                isDay: true
            ),
            hourly: [],
            daily: []
        )
    }
}
