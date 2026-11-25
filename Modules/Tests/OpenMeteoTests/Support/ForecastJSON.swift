enum ForecastJSON {
    static let dayStart = 1795474800
    static let sunrise = 1795500698
    static let sunset = 1795530787
    static let noon = 1795518000

    static func make(
        timezone: String = "Europe/Warsaw",
        weatherCode: Int = 3,
        uvIndex: Double? = 0,
        cape: Double? = 0,
        liftedIndex: Double? = 6.9,
        sunrise: Int = sunrise,
        sunset: Int = sunset,
        hourlyTimes: [Int] = [noon],
        dailyTimes: [Int] = [dayStart]
    ) -> String {
        """
        {
          "latitude": 52.23,
          "longitude": 21.01,
          "timezone": "\(timezone)",
          "utc_offset_seconds": 3600,
          "current": {
            "time": 1795547700,
            "interval": 900,
            "temperature_2m": 3.2,
            "apparent_temperature": -1.3,
            "precipitation_probability": 38,
            "relative_humidity_2m": 89,
            "visibility": 7140.0,
            "uv_index": \(json(uvIndex)),
            "wind_speed_10m": 18.4,
            "wind_gusts_10m": 40.7,
            "wind_direction_10m": 305,
            "weather_code": \(weatherCode),
            "is_day": 0
          },
          "hourly": {
            "time": [\(hourlyTimes.map(String.init).joined(separator: ","))],
            "temperature_2m": [3.1],
            "precipitation_probability": [12],
            "weather_code": [61],
            "is_day": [1],
            "cape": [\(json(cape))],
            "lifted_index": [\(json(liftedIndex))]
          },
          "daily": {
            "time": [\(dailyTimes.map(String.init).joined(separator: ","))],
            "weather_code": [53],
            "temperature_2m_max": [3.5],
            "temperature_2m_min": [1.1],
            "precipitation_probability_max": [100],
            "sunrise": [\(sunrise)],
            "sunset": [\(sunset)]
          }
        }
        """
    }

    private static func json(_ value: Double?) -> String {
        value.map { String($0) } ?? "null"
    }
}
