import Domain
import Foundation
import OpenMeteo
import Testing

struct OpenMeteoWeatherSummaryTests {
    private let gdansk = Coordinate(latitude: 54.35, longitude: 18.65)
    private let wroclaw = Coordinate(latitude: 51.1, longitude: 17.03)

    @Test func requestsAllCoordinatesAtOnce() async throws {
        let json = SummaryJSON.locations(SummaryJSON.location(), SummaryJSON.location())
        let httpClient = StubHTTPClient(json: json)
        let provider = OpenMeteoForecastProvider(httpClient: httpClient)

        _ = try await provider.summaries(for: [gdansk, wroclaw])

        #expect(httpClient.requests.count == 1)
        let url = try #require(httpClient.requests.first?.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.host == "api.open-meteo.com")
        #expect(components.path == "/v1/forecast")
        #expect(components.queryItems?.first { $0.name == "latitude" }?.value == "54.35,51.1")
        #expect(components.queryItems?.first { $0.name == "longitude" }?.value == "18.65,17.03")
        #expect(components.queryItems?.first { $0.name == "current" }?.value == "temperature_2m,weather_code,is_day")
        #expect(components.queryItems?.first { $0.name == "daily" }?.value == "temperature_2m_max,temperature_2m_min")
        #expect(components.queryItems?.first { $0.name == "temperature_unit" }?.value == "celsius")
        #expect(components.queryItems?.first { $0.name == "timezone" }?.value == "auto")
        #expect(components.queryItems?.first { $0.name == "forecast_days" }?.value == "1")
    }

    @Test func matchesSummariesToCoordinatesInRequestOrder() async throws {
        let json = SummaryJSON.locations(
            SummaryJSON.location(),
            SummaryJSON.location(temperature: 1.4, weatherCode: 61, isDay: 0, maxTemperatures: [1.5], minTemperatures: [0.1])
        )
        let provider = OpenMeteoForecastProvider(httpClient: StubHTTPClient(json: json))

        let summaries = try await provider.summaries(for: [gdansk, wroclaw])

        #expect(summaries == [
            gdansk: WeatherSummary(
                temperature: Measurement(value: 3.3, unit: .celsius),
                minTemperature: Measurement(value: -0.6, unit: .celsius),
                maxTemperature: Measurement(value: 3.6, unit: .celsius),
                condition: .overcast,
                isDay: true
            ),
            wroclaw: WeatherSummary(
                temperature: Measurement(value: 1.4, unit: .celsius),
                minTemperature: Measurement(value: 0.1, unit: .celsius),
                maxTemperature: Measurement(value: 1.5, unit: .celsius),
                condition: .rain,
                isDay: false
            ),
        ])
    }

    @Test func decodesSingleLocationResponse() async throws {
        let provider = OpenMeteoForecastProvider(httpClient: StubHTTPClient(json: SummaryJSON.location()))

        let summaries = try await provider.summaries(for: [gdansk])

        #expect(summaries[gdansk]?.temperature == Measurement(value: 3.3, unit: .celsius))
    }

    @Test func requestsRepeatedCoordinateOnce() async throws {
        let httpClient = StubHTTPClient(json: SummaryJSON.location())
        let provider = OpenMeteoForecastProvider(httpClient: httpClient)

        let summaries = try await provider.summaries(for: [gdansk, gdansk])

        let url = try #require(httpClient.requests.first?.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.first { $0.name == "latitude" }?.value == "54.35")
        #expect(Array(summaries.keys) == [gdansk])
    }

    @Test func keepsRequestOrderWhenCoordinatesRepeat() async throws {
        let json = SummaryJSON.locations(
            SummaryJSON.location(),
            SummaryJSON.location(temperature: 1.4, weatherCode: 61, isDay: 0, maxTemperatures: [1.5], minTemperatures: [0.1])
        )
        let httpClient = StubHTTPClient(json: json)
        let provider = OpenMeteoForecastProvider(httpClient: httpClient)

        let summaries = try await provider.summaries(for: [gdansk, wroclaw, gdansk])

        let url = try #require(httpClient.requests.first?.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.first { $0.name == "latitude" }?.value == "54.35,51.1")
        #expect(components.queryItems?.first { $0.name == "longitude" }?.value == "18.65,17.03")
        #expect(summaries.count == 2)
        #expect(summaries[gdansk]?.temperature == Measurement(value: 3.3, unit: .celsius))
        #expect(summaries[wroclaw]?.temperature == Measurement(value: 1.4, unit: .celsius))
    }

    @Test func sendsNoRequestWithoutCoordinates() async throws {
        let httpClient = StubHTTPClient(json: SummaryJSON.locations())
        let provider = OpenMeteoForecastProvider(httpClient: httpClient)

        let summaries = try await provider.summaries(for: [])

        #expect(summaries.isEmpty)
        #expect(httpClient.requests.isEmpty)
    }

    @Test(arguments: [
        SummaryJSON.locations(SummaryJSON.location()),
        SummaryJSON.locations(SummaryJSON.location(), SummaryJSON.location(maxTemperatures: [], minTemperatures: [])),
    ])
    func reportsServerErrorForIncompleteResponse(json: String) async {
        let provider = OpenMeteoForecastProvider(httpClient: StubHTTPClient(json: json))

        await #expect(throws: WeatherError.server) {
            try await provider.summaries(for: [gdansk, wroclaw])
        }
    }
}
