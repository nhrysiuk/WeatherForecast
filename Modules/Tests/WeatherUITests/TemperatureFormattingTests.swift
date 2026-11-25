import Foundation
import Testing
import WeatherUI

struct TemperatureFormattingTests {
    @Test(arguments: [
        (-4.6, "pl_PL", "-5°"),
        (-0.3, "pl_PL", "0°"),
        (21.6, "en_US", "71°"),
    ])
    func formatsWholeDegreesInLocaleUnit(celsius: Double, localeIdentifier: String, expected: String) {
        let temperature = Measurement(value: celsius, unit: UnitTemperature.celsius)

        #expect(temperature.formattedTemperature(locale: Locale(identifier: localeIdentifier)) == expected)
    }
}
