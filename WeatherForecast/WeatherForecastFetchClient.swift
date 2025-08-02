import Foundation
import ComposableArchitecture

struct WeatherForecastFetchClient {
    var fetch: (String) async throws -> [DayForecast]
}

extension WeatherForecastFetchClient: DependencyKey {
    static let liveValue = Self(
        fetch: { cityName in
            let coordinates: [CoordinateData]? = await fetchData(url: "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=a066f4a8bf5b6cb3985b36c2d99574b8")
            guard let coordinates else { return [] }
            
            let data: WeatherForecastData? = await fetchData(url: "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinates[0].latitude)&lon=\(coordinates[0].longitude)&appid=a066f4a8bf5b6cb3985b36c2d99574b8")
            guard let data else { return [] }
            
            let filteredData = filterForecastData(data)
            return filteredData
        }
    )
    
    private static func fetchData<T: Decodable>(url: String) async -> T? {
        guard let url = URL(string: url) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    private static func filterForecastData(_ data: WeatherForecastData) -> [DayForecast] {
        let res = data.list
            .filter { $0.dtTxt.hasSuffix("15:00:00") }
            .map { DayForecast(from: $0) }
        return res
    }
}

extension DependencyValues {
    var forecast: WeatherForecastFetchClient {
        get { self[WeatherForecastFetchClient.self] }
        set { self[WeatherForecastFetchClient.self] = newValue }
    }
}
