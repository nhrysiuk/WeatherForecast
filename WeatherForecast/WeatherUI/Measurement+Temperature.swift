import Foundation

extension Measurement where UnitType == UnitTemperature {
    func formattedTemperature(locale: Locale = .autoupdatingCurrent) -> String {
        let unit = UnitTemperature(forLocale: locale, usage: .weather)
        let degrees = Int(converted(to: unit).value.rounded())
        return degrees.formatted(.number.locale(locale)) + "°"
    }
}
