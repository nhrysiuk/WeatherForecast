import Testing
@testable import WeatherForecast

struct TemperatureColorScaleTests {
    @Test func sameTemperatureHasSameColorInAnyRange() {
        let narrow = TemperatureColorScale.stops(for: 0...5)
        let wide = TemperatureColorScale.stops(for: -20...0)

        #expect(narrow.first?.rgb == wide.last?.rgb)
        #expect(narrow.first?.rgb == TemperatureColorScale.rgb(celsius: 0))
    }

    @Test func addsAnchorColorsInsideTheRange() {
        let stops = TemperatureColorScale.stops(for: -5...25)

        let expected: [Double] = [0, 5.0 / 30, 15.0 / 30, 25.0 / 30, 1]

        #expect(stops.map(\.location) == expected)
        #expect(stops[1].rgb == TemperatureColorScale.rgb(celsius: 0))
        #expect(stops[2].rgb == TemperatureColorScale.rgb(celsius: 10))
    }

    @Test func clampsTemperaturesOutsideTheScale() {
        #expect(TemperatureColorScale.rgb(celsius: -50) == TemperatureColorScale.rgb(celsius: -30))
        #expect(TemperatureColorScale.rgb(celsius: 55) == TemperatureColorScale.rgb(celsius: 40))
    }

    @Test func usesOneColorWhenMinimumEqualsMaximum() {
        let stops = TemperatureColorScale.stops(for: 12...12)

        #expect(stops.count == 2)
        #expect(stops[0].rgb == stops[1].rgb)
    }
}
