import Domain
import Foundation
import Testing

struct ThunderstormRiskTests {
    @Test(arguments: [
        (WeatherCondition.thunderstorm, nil, nil, true),
        (.clear, 1000, -2, true),
        (.clear, 999, -5, false),
        (.clear, 2500, -1.9, false),
        (.clear, nil, -5, false),
    ] as [(WeatherCondition, Double?, Double?, Bool)])
    func detectsRisk(condition: WeatherCondition, cape: Double?, liftedIndex: Double?, expected: Bool) {
        let hour = HourlyForecast(
            time: .now,
            temperature: Measurement(value: 20, unit: .celsius),
            precipitationProbability: 0,
            condition: condition,
            isDay: true,
            cape: cape,
            liftedIndex: liftedIndex
        )

        #expect(hour.hasThunderstormRisk == expected)
    }
}
