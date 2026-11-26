import Foundation

extension Measurement where UnitType == UnitTemperature {
    func formattedTemperature(scale: TemperatureScale? = nil, locale: Locale = .autoupdatingCurrent) -> String {
        let unit = (scale ?? TemperatureScale(locale: locale)).unit
        let degrees = Int(converted(to: unit).value.rounded())
        return degrees.formatted(.number.locale(locale)) + "°"
    }
}
