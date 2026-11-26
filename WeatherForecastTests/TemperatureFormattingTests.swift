import Foundation
import Testing
@testable import WeatherForecast

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

    @Test(arguments: [
        (21.6, TemperatureScale.fahrenheit, "pl_PL", "71°"),
        (21.6, TemperatureScale.celsius, "en_US", "22°"),
        (-17.8, TemperatureScale.fahrenheit, "en_US", "0°"),
    ])
    func formatsWholeDegreesInChosenScale(celsius: Double, scale: TemperatureScale, localeIdentifier: String, expected: String) {
        let temperature = Measurement(value: celsius, unit: UnitTemperature.celsius)

        #expect(temperature.formattedTemperature(scale: scale, locale: Locale(identifier: localeIdentifier)) == expected)
    }

    @Test(arguments: [
        ("en_US", TemperatureScale.fahrenheit),
        ("pl_PL", TemperatureScale.celsius),
        ("en_GB", TemperatureScale.celsius),
    ])
    func defaultsToLocaleScale(localeIdentifier: String, expected: TemperatureScale) {
        #expect(TemperatureScale(locale: Locale(identifier: localeIdentifier)) == expected)
    }
}
