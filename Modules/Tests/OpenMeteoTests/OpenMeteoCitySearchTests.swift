import Domain
import Foundation
import Networking
import OpenMeteo
import Testing

struct OpenMeteoCitySearchTests {
    @Test func sendsNameAndLanguageToGeocodingAPI() async throws {
        let httpClient = StubHTTPClient(json: "{}")
        let search = OpenMeteoCitySearch(httpClient: httpClient, locale: Locale(identifier: "pl_PL"))

        _ = try await search.searchCities(named: "Zielona Góra")

        let url = try #require(httpClient.requests.first?.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.host == "geocoding-api.open-meteo.com")
        #expect(components.path == "/v1/search")
        #expect(components.queryItems?.first { $0.name == "name" }?.value == "Zielona Góra")
        #expect(components.queryItems?.first { $0.name == "count" }?.value == "10")
        #expect(components.queryItems?.first { $0.name == "language" }?.value == "pl")
    }

    @Test func mapsPlacesToCities() async throws {
        let httpClient = StubHTTPClient(json: """
        {
          "results": [
            {
              "id": 3094802,
              "name": "Kraków",
              "latitude": 50.06143,
              "longitude": 19.93658,
              "elevation": 219.0,
              "country_code": "PL",
              "timezone": "Europe/Warsaw",
              "admin1": "Lesser Poland"
            },
            {
              "id": 702550,
              "name": "Lviv",
              "latitude": 49.83826,
              "longitude": 24.02324,
              "timezone": "Europe/Kyiv"
            }
          ]
        }
        """)
        let search = OpenMeteoCitySearch(httpClient: httpClient, locale: Locale(identifier: "en_US"))

        let cities = try await search.searchCities(named: "Kraków")

        #expect(cities == [
            City(
                id: 3094802,
                name: "Kraków",
                region: "Lesser Poland",
                countryCode: "PL",
                coordinate: Coordinate(latitude: 50.06143, longitude: 19.93658)
            ),
            City(
                id: 702550,
                name: "Lviv",
                region: nil,
                countryCode: nil,
                coordinate: Coordinate(latitude: 49.83826, longitude: 24.02324)
            ),
        ])
    }

    @Test func keepsOnlyInhabitedPlaces() async throws {
        let httpClient = StubHTTPClient(json: """
        {
          "results": [
            { "id": 1, "name": "Gdańsk", "latitude": 0, "longitude": 0, "timezone": "Europe/Warsaw", "feature_code": "PPLA" },
            { "id": 2, "name": "Gdańsk Airport", "latitude": 0, "longitude": 0, "timezone": "Europe/Warsaw", "feature_code": "AIRP" },
            { "id": 3, "name": "Old Gdańsk", "latitude": 0, "longitude": 0, "timezone": "Europe/Warsaw", "feature_code": "PPLQ" },
            { "id": 4, "name": "Gdańsk Park", "latitude": 0, "longitude": 0, "timezone": "Europe/Warsaw", "feature_code": "PRK" },
            { "id": 5, "name": "Wrzeszcz", "latitude": 0, "longitude": 0, "timezone": "Europe/Warsaw", "feature_code": "PPLX" },
            { "id": 6, "name": "Oliwa", "latitude": 0, "longitude": 0, "timezone": "Europe/Warsaw" }
          ]
        }
        """)
        let search = OpenMeteoCitySearch(httpClient: httpClient, locale: Locale(identifier: "en_US"))

        let cities = try await search.searchCities(named: "Gdańsk")

        #expect(cities.map(\.id) == [1, 5, 6])
    }

    @Test func returnsNoCitiesWhenNothingMatches() async throws {
        let httpClient = StubHTTPClient(json: #"{"generationtime_ms":0.12}"#)
        let search = OpenMeteoCitySearch(httpClient: httpClient, locale: Locale(identifier: "en_US"))

        #expect(try await search.searchCities(named: "Qwerty").isEmpty)
    }

    @Test func reportsOfflineWhenThereIsNoConnection() async {
        let httpClient = StubHTTPClient(result: .failure(NetworkError.offline))
        let search = OpenMeteoCitySearch(httpClient: httpClient, locale: Locale(identifier: "en_US"))

        await #expect(throws: WeatherError.offline) {
            try await search.searchCities(named: "Gdańsk")
        }
    }

    @Test(arguments: [
        Result<Data, any Error>.failure(NetworkError.unacceptableStatusCode(400)),
        .success(Data("not json".utf8)),
    ])
    func reportsServerErrorForOtherFailures(result: Result<Data, any Error>) async {
        let search = OpenMeteoCitySearch(httpClient: StubHTTPClient(result: result), locale: Locale(identifier: "en_US"))

        await #expect(throws: WeatherError.server) {
            try await search.searchCities(named: "Gdańsk")
        }
    }

    @Test func passesCancellationThrough() async {
        let httpClient = StubHTTPClient(result: .failure(CancellationError()))
        let search = OpenMeteoCitySearch(httpClient: httpClient, locale: Locale(identifier: "en_US"))

        await #expect(throws: CancellationError.self) {
            try await search.searchCities(named: "Gdańsk")
        }
    }
}
