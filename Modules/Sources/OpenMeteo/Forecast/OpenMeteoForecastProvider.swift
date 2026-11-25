import Domain
import Foundation
import Networking

public struct OpenMeteoForecastProvider: ForecastProviding {
    private static let forecastURL = URL(string: "https://api.open-meteo.com/v1/forecast")!
    private static let dayCount = 7

    private let httpClient: any HTTPClient

    public init(httpClient: any HTTPClient) {
        self.httpClient = httpClient
    }

    public func forecast(for coordinate: Coordinate) async throws -> Forecast {
        let url = Self.forecastURL.appending(queryItems: [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "current", value: ForecastResponse.Current.requestedFields),
            URLQueryItem(name: "hourly", value: ForecastResponse.Hourly.requestedFields),
            URLQueryItem(name: "daily", value: ForecastResponse.Daily.requestedFields),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "wind_speed_unit", value: "kmh"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "timeformat", value: "unixtime"),
            URLQueryItem(name: "forecast_days", value: String(Self.dayCount)),
        ])
        let response = try await httpClient.response(ForecastResponse.self, for: URLRequest(url: url))
        return try response.makeForecast()
    }

    public func summaries(for coordinates: [Coordinate]) async throws -> [Coordinate: WeatherSummary] {
        guard !coordinates.isEmpty else {
            return [:]
        }
        var seen = Set<Coordinate>()
        let uniqueCoordinates = coordinates.filter { seen.insert($0).inserted }
        let url = Self.forecastURL.appending(queryItems: [
            URLQueryItem(name: "latitude", value: uniqueCoordinates.map { String($0.latitude) }.joined(separator: ",")),
            URLQueryItem(name: "longitude", value: uniqueCoordinates.map { String($0.longitude) }.joined(separator: ",")),
            URLQueryItem(name: "current", value: SummaryResponse.Current.requestedFields),
            URLQueryItem(name: "daily", value: SummaryResponse.Daily.requestedFields),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "1"),
        ])
        let request = URLRequest(url: url)
        let responses = if uniqueCoordinates.count == 1 {
            [try await httpClient.response(SummaryResponse.self, for: request)]
        } else {
            try await httpClient.response([SummaryResponse].self, for: request)
        }
        guard responses.count == uniqueCoordinates.count else {
            throw WeatherError.server
        }
        return try Dictionary(
            uniqueKeysWithValues: zip(uniqueCoordinates, responses).map { ($0, try $1.makeSummary()) }
        )
    }
}
