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
}
