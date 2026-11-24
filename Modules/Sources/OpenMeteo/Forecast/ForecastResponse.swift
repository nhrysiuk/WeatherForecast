import Domain
import Foundation

struct ForecastResponse: Decodable {
    struct Current: Decodable {
        let temperature: Double
        let apparentTemperature: Double
        let cloudCover: Int
        let precipitationProbability: Int
        let relativeHumidity: Int
        let pressure: Double
        let visibility: Double
        let uvIndex: Double?
        let windSpeed: Double
        let windGusts: Double
        let windDirection: Double
        let weatherCode: Int
        let isDay: Int

        enum CodingKeys: String, CodingKey, CaseIterable {
            case temperature = "temperature_2m"
            case apparentTemperature = "apparent_temperature"
            case cloudCover = "cloud_cover"
            case precipitationProbability = "precipitation_probability"
            case relativeHumidity = "relative_humidity_2m"
            case pressure = "pressure_msl"
            case visibility
            case uvIndex = "uv_index"
            case windSpeed = "wind_speed_10m"
            case windGusts = "wind_gusts_10m"
            case windDirection = "wind_direction_10m"
            case weatherCode = "weather_code"
            case isDay = "is_day"
        }

        static let requestedFields = CodingKeys.queryValue()
    }

    struct Hourly: Decodable {
        let time: [TimeInterval]
        let temperature: [Double]
        let precipitationProbability: [Int]
        let weatherCode: [Int]
        let isDay: [Int]
        let cape: [Double?]
        let liftedIndex: [Double?]

        enum CodingKeys: String, CodingKey, CaseIterable {
            case time
            case temperature = "temperature_2m"
            case precipitationProbability = "precipitation_probability"
            case weatherCode = "weather_code"
            case isDay = "is_day"
            case cape
            case liftedIndex = "lifted_index"
        }

        static let requestedFields = CodingKeys.queryValue(excluding: .time)
    }

    struct Daily: Decodable {
        let time: [TimeInterval]
        let weatherCode: [Int]
        let maxTemperature: [Double]
        let minTemperature: [Double]
        let precipitationProbability: [Int]
        let sunrise: [TimeInterval]
        let sunset: [TimeInterval]
        let moonPhase: [Double]

        enum CodingKeys: String, CodingKey, CaseIterable {
            case time
            case weatherCode = "weather_code"
            case maxTemperature = "temperature_2m_max"
            case minTemperature = "temperature_2m_min"
            case precipitationProbability = "precipitation_probability_max"
            case sunrise
            case sunset
            case moonPhase = "moon_phase"
        }

        static let requestedFields = CodingKeys.queryValue(excluding: .time)
    }

    let timezone: String
    let utcOffsetSeconds: Int
    let current: Current
    let hourly: Hourly
    let daily: Daily

    enum CodingKeys: String, CodingKey {
        case timezone
        case utcOffsetSeconds = "utc_offset_seconds"
        case current
        case hourly
        case daily
    }
}

extension ForecastResponse {
    func makeForecast() throws -> Forecast {
        let timeZone = TimeZone(identifier: timezone) ?? TimeZone(secondsFromGMT: utcOffsetSeconds) ?? .gmt
        return Forecast(
            timeZone: timeZone,
            current: current.conditions,
            hourly: try hourly.makeForecasts(),
            daily: try daily.makeForecasts(in: timeZone)
        )
    }
}

extension ForecastResponse.Current {
    var conditions: CurrentConditions {
        CurrentConditions(
            temperature: Measurement(value: temperature, unit: .celsius),
            apparentTemperature: Measurement(value: apparentTemperature, unit: .celsius),
            cloudCover: cloudCover,
            precipitationProbability: precipitationProbability,
            relativeHumidity: relativeHumidity,
            pressure: Measurement(value: pressure, unit: .hectopascals),
            visibility: Measurement(value: visibility, unit: .meters),
            uvIndex: uvIndex,
            wind: Wind(
                speed: Measurement(value: windSpeed, unit: .kilometersPerHour),
                gusts: Measurement(value: windGusts, unit: .kilometersPerHour),
                direction: Measurement(value: windDirection, unit: .degrees)
            ),
            condition: WeatherCondition(wmoCode: weatherCode),
            isDay: isDay == 1
        )
    }
}

extension ForecastResponse.Hourly {
    func makeForecasts() throws -> [HourlyForecast] {
        try requireEqualLengths(
            time.count,
            temperature.count,
            precipitationProbability.count,
            weatherCode.count,
            isDay.count,
            cape.count,
            liftedIndex.count
        )
        return time.indices.map { index in
            HourlyForecast(
                time: Date(timeIntervalSince1970: time[index]),
                temperature: Measurement(value: temperature[index], unit: .celsius),
                precipitationProbability: precipitationProbability[index],
                condition: WeatherCondition(wmoCode: weatherCode[index]),
                isDay: isDay[index] == 1,
                cape: cape[index],
                liftedIndex: liftedIndex[index]
            )
        }
    }
}

extension ForecastResponse.Daily {
    func makeForecasts(in timeZone: TimeZone) throws -> [DailyForecast] {
        try requireEqualLengths(
            time.count,
            weatherCode.count,
            maxTemperature.count,
            minTemperature.count,
            precipitationProbability.count,
            sunrise.count,
            sunset.count,
            moonPhase.count
        )
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return time.indices.map { index in
            let date = Date(timeIntervalSince1970: time[index])
            let day = calendar.dateInterval(of: .day, for: date)
            return DailyForecast(
                date: date,
                minTemperature: Measurement(value: minTemperature[index], unit: .celsius),
                maxTemperature: Measurement(value: maxTemperature[index], unit: .celsius),
                precipitationProbability: precipitationProbability[index],
                condition: WeatherCondition(wmoCode: weatherCode[index]),
                sunrise: Self.event(at: sunrise[index], within: day),
                sunset: Self.event(at: sunset[index], within: day),
                moonPhase: moonPhase[index]
            )
        }
    }

    private static func event(at timestamp: TimeInterval, within day: DateInterval?) -> Date? {
        let date = Date(timeIntervalSince1970: timestamp)
        guard let day, date > day.start, date < day.end else {
            return nil
        }
        return date
    }
}

private func requireEqualLengths(_ counts: Int...) throws {
    guard Set(counts).count <= 1 else {
        throw WeatherError.server
    }
}
