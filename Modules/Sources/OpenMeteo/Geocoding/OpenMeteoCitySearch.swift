import Domain
import Foundation
import Networking

public struct OpenMeteoCitySearch: CitySearching {
    private static let searchURL = URL(string: "https://geocoding-api.open-meteo.com/v1/search")!
    private static let resultLimit = 10
    private static let fallbackLanguageCode = "en"

    private let httpClient: any HTTPClient
    private let languageCode: String

    public init(httpClient: any HTTPClient, locale: Locale) {
        self.httpClient = httpClient
        self.languageCode = locale.language.languageCode?.identifier ?? Self.fallbackLanguageCode
    }

    public func searchCities(named name: String) async throws -> [City] {
        let url = Self.searchURL.appending(queryItems: [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "count", value: String(Self.resultLimit)),
            URLQueryItem(name: "language", value: languageCode),
        ])
        let response = try await httpClient.response(GeocodingResponse.self, for: URLRequest(url: url))
        return response.results?.compactMap(\.city) ?? []
    }
}
