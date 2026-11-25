import Domain
import Foundation

struct SummaryResponse: Decodable {
    struct Current: Decodable {
        let temperature: Double
        let weatherCode: Int
        let isDay: Int

        enum CodingKeys: String, CodingKey, CaseIterable {
            case temperature = "temperature_2m"
            case weatherCode = "weather_code"
            case isDay = "is_day"
        }

        static let requestedFields = CodingKeys.queryValue()
    }

    struct Daily: Decodable {
        let maxTemperature: [Double]
        let minTemperature: [Double]

        enum CodingKeys: String, CodingKey, CaseIterable {
            case maxTemperature = "temperature_2m_max"
            case minTemperature = "temperature_2m_min"
        }

        static let requestedFields = CodingKeys.queryValue()
    }

    let current: Current
    let daily: Daily
}

extension SummaryResponse {
    func makeSummary() throws -> WeatherSummary {
        guard let maxTemperature = daily.maxTemperature.first, let minTemperature = daily.minTemperature.first else {
            throw WeatherError.server
        }
        return WeatherSummary(
            temperature: Measurement(value: current.temperature, unit: .celsius),
            minTemperature: Measurement(value: minTemperature, unit: .celsius),
            maxTemperature: Measurement(value: maxTemperature, unit: .celsius),
            condition: WeatherCondition(wmoCode: current.weatherCode),
            isDay: current.isDay == 1
        )
    }
}
