import Foundation
import ComposableArchitecture

struct WeatherForecastFetchClient {
    
    var fetch: (String) async throws -> [DayForecast]
}

extension WeatherForecastFetchClient: DependencyKey {
    
    static let liveValue = Self(
        fetch: { cityName in
            let coordinates: [CoordinateData]? = await fetchData(url: "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=a066f4a8bf5b6cb3985b36c2d99574b8")
            guard let coordinates, let coordinate = coordinates.first else { return [] }
            
            let data: WeatherForecastData? = await fetchData(url: "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=a066f4a8bf5b6cb3985b36c2d99574b8")
            guard let data else { return [] }
            
            var filteredData = processForecastData(data, cityName: coordinate.name)
            
            return filteredData
        }
    )
    
    private static func fetchData<T: Decodable>(url: String) async -> T? {
        guard let url = URL(string: url) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedValue = try JSONDecoder().decode(T.self, from: data)
            if let arr = decodedValue as? [Any], arr.isEmpty {
                return nil
            }
            return decodedValue
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private static func processForecastData(_ data: WeatherForecastData, cityName: String) -> [DayForecast] {
        return data.list
            .filter { $0.dtTxt.hasSuffix("15:00:00") }
            .map { DayForecast(from: $0, cityName: cityName)}
    }
}

extension DependencyValues {
    
    var weatherForecast: WeatherForecastFetchClient {
        get { self[WeatherForecastFetchClient.self] }
        set { self[WeatherForecastFetchClient.self] = newValue }
    }
}
