import Domain
import Foundation
import OpenMeteo
import Testing

struct OpenMeteoForecastProviderTests {
    private let coordinate = Coordinate(latitude: 52.23, longitude: 21.01)

    @Test func sendsCoordinateAndFormatToForecastAPI() async throws {
        let httpClient = StubHTTPClient(json: ForecastJSON.make())
        let provider = OpenMeteoForecastProvider(httpClient: httpClient)

        _ = try await provider.forecast(for: coordinate)

        let url = try #require(httpClient.requests.first?.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.host == "api.open-meteo.com")
        #expect(components.path == "/v1/forecast")
        #expect(components.queryItems?.first { $0.name == "latitude" }?.value == "52.23")
        #expect(components.queryItems?.first { $0.name == "longitude" }?.value == "21.01")
        #expect(components.queryItems?.first { $0.name == "timezone" }?.value == "auto")
        #expect(components.queryItems?.first { $0.name == "timeformat" }?.value == "unixtime")
        #expect(components.queryItems?.first { $0.name == "temperature_unit" }?.value == "celsius")
        #expect(components.queryItems?.first { $0.name == "wind_speed_unit" }?.value == "kmh")
        #expect(components.queryItems?.first { $0.name == "forecast_days" }?.value == "7")
        #expect(components.queryItems?.first { $0.name == "current" }?.value == [
            "temperature_2m", "apparent_temperature", "precipitation_probability",
            "relative_humidity_2m", "visibility", "uv_index", "wind_speed_10m",
            "wind_gusts_10m", "wind_direction_10m", "weather_code", "is_day",
        ].joined(separator: ","))
        #expect(components.queryItems?.first { $0.name == "hourly" }?.value == [
            "temperature_2m", "precipitation_probability", "weather_code", "is_day", "cape", "lifted_index",
        ].joined(separator: ","))
        #expect(components.queryItems?.first { $0.name == "daily" }?.value == [
            "weather_code", "temperature_2m_max", "temperature_2m_min", "precipitation_probability_max",
            "sunrise", "sunset",
        ].joined(separator: ","))
    }

    @Test func mapsResponseToForecast() async throws {
        let provider = OpenMeteoForecastProvider(httpClient: StubHTTPClient(json: ForecastJSON.make()))

        let forecast = try await provider.forecast(for: coordinate)

        #expect(forecast == Forecast(
            timeZone: TimeZone(identifier: "Europe/Warsaw")!,
            current: CurrentConditions(
                temperature: Measurement(value: 3.2, unit: .celsius),
                apparentTemperature: Measurement(value: -1.3, unit: .celsius),
                precipitationProbability: 38,
                relativeHumidity: 89,
                visibility: Measurement(value: 7140, unit: .meters),
                uvIndex: 0,
                wind: Wind(
                    speed: Measurement(value: 18.4, unit: .kilometersPerHour),
                    gusts: Measurement(value: 40.7, unit: .kilometersPerHour),
                    direction: Measurement(value: 305, unit: .degrees)
                ),
                condition: .overcast,
                isDay: false
            ),
            hourly: [
                HourlyForecast(
                    time: Date(timeIntervalSince1970: TimeInterval(ForecastJSON.noon)),
                    temperature: Measurement(value: 3.1, unit: .celsius),
                    precipitationProbability: 12,
                    condition: .rain,
                    isDay: true,
                    cape: 0,
                    liftedIndex: 6.9
                ),
            ],
            daily: [
                DailyForecast(
                    date: Date(timeIntervalSince1970: TimeInterval(ForecastJSON.dayStart)),
                    minTemperature: Measurement(value: 1.1, unit: .celsius),
                    maxTemperature: Measurement(value: 3.5, unit: .celsius),
                    precipitationProbability: 100,
                    condition: .drizzle,
                    sunrise: Date(timeIntervalSince1970: TimeInterval(ForecastJSON.sunrise)),
                    sunset: Date(timeIntervalSince1970: TimeInterval(ForecastJSON.sunset))
                ),
            ]
        ))
    }

    @Test func leavesMissingIndicesEmpty() async throws {
        let json = ForecastJSON.make(uvIndex: nil, cape: nil, liftedIndex: nil)
        let provider = OpenMeteoForecastProvider(httpClient: StubHTTPClient(json: json))

        let forecast = try await provider.forecast(for: coordinate)

        #expect(forecast.current.uvIndex == nil)
        #expect(forecast.hourly.first?.cape == nil)
        #expect(forecast.hourly.first?.liftedIndex == nil)
    }

    @Test(arguments: [
        ForecastJSON.make(hourlyTimes: [ForecastJSON.noon, ForecastJSON.noon + 3_600]),
        ForecastJSON.make(dailyTimes: [ForecastJSON.dayStart, ForecastJSON.dayStart + 86_400]),
    ])
    func reportsServerErrorWhenValuesDoNotLineUp(json: String) async {
        let provider = OpenMeteoForecastProvider(httpClient: StubHTTPClient(json: json))

        await #expect(throws: WeatherError.server) {
            try await provider.forecast(for: coordinate)
        }
    }

    @Test(arguments: [
        (ForecastJSON.dayStart, ForecastJSON.dayStart),
        (ForecastJSON.dayStart, ForecastJSON.dayStart + 86_400),
    ])
    func hasNoSunriseOrSunsetDuringPolarNightOrDay(sunrise: Int, sunset: Int) async throws {
        let json = ForecastJSON.make(timezone: "Arctic/Longyearbyen", sunrise: sunrise, sunset: sunset)
        let provider = OpenMeteoForecastProvider(httpClient: StubHTTPClient(json: json))

        let day = try #require(try await provider.forecast(for: coordinate).daily.first)

        #expect(day.sunrise == nil)
        #expect(day.sunset == nil)
    }

    @Test(arguments: [
        (0, WeatherCondition.clear),
        (2, .partlyCloudy),
        (3, .overcast),
        (45, .fog),
        (53, .drizzle),
        (66, .freezingRain),
        (63, .rain),
        (85, .snow),
        (81, .showers),
        (96, .thunderstorm),
        (4, .unknown),
    ])
    func mapsWeatherCodes(code: Int, condition: WeatherCondition) async throws {
        let provider = OpenMeteoForecastProvider(httpClient: StubHTTPClient(json: ForecastJSON.make(weatherCode: code)))

        #expect(try await provider.forecast(for: coordinate).current.condition == condition)
    }
}
