enum SummaryJSON {
    static func location(
        temperature: Double = 3.3,
        weatherCode: Int = 3,
        isDay: Int = 1,
        maxTemperatures: [Double] = [3.6],
        minTemperatures: [Double] = [-0.6]
    ) -> String {
        """
        {
          "latitude": 54.355087,
          "longitude": 18.63427,
          "timezone": "Europe/Warsaw",
          "utc_offset_seconds": 3600,
          "current": {
            "time": 1795611600,
            "interval": 900,
            "temperature_2m": \(temperature),
            "weather_code": \(weatherCode),
            "is_day": \(isDay)
          },
          "daily": {
            "time": [1795561200],
            "temperature_2m_max": [\(list(maxTemperatures))],
            "temperature_2m_min": [\(list(minTemperatures))]
          }
        }
        """
    }

    static func locations(_ locations: String...) -> String {
        "[\(locations.joined(separator: ","))]"
    }

    private static func list(_ values: [Double]) -> String {
        values.map { String($0) }.joined(separator: ",")
    }
}
