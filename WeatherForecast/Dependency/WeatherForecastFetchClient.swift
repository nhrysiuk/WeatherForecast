import Foundation
import ComposableArchitecture

struct WeatherForecastFetchClient {
    
    var fetch: (String) async throws -> [DayForecast]
}

enum WeatherForecastError: Error, LocalizedError, Equatable {
    case invalidCity
    case networkError
    case invalidResponse
    case emptyInput
    
    var errorDescription: String? {
        switch self {
        case .invalidCity:
            "City not found. Please check the spelling and try again."
        case .networkError:
            "Network connection error. Please check your internet connection and try again."
        case .invalidResponse:
            "Unable to fetch weather data. Please try again later."
        case .emptyInput:
            "Please enter a city name."
        }
    }
    
    var uiMessage: (String, String) {
        switch self {
        case .invalidCity:
            ("Oops! We don't have any forecast for that city. Double-check the name and try again.", "exclamationmark.warninglight.fill")
        case .emptyInput:
            ("Enter city name to see the forecast.", "pencil.line")
        case .networkError:
            ("Seems like the internet connection is lost.", "network.slash")
        case .invalidResponse:
            ("Unable to fetch weather data. Please try again later.", "exclamationmark.triangle.fill")
        }
    }
}

extension WeatherForecastFetchClient: DependencyKey {
    
    static let liveValue = Self(
        fetch: { cityName in
            let coordinates: [CoordinateData]? = try await fetchData(url: "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=a066f4a8bf5b6cb3985b36c2d99574b8")
            guard let coordinates, let coordinate = coordinates.first else {
                throw WeatherForecastError.invalidCity
            }
            
            let data: WeatherForecastData? = try await fetchData(url: "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=a066f4a8bf5b6cb3985b36c2d99574b8")
            guard let data else {
                throw WeatherForecastError.invalidResponse
            }
            
            let filteredData = processForecastData(data, cityName: coordinate.name)
            
            return filteredData
        }
    )
    
    private static func fetchData<T: Decodable>(url: String) async throws -> T? {
        guard let url = URL(string: url) else { 
            throw WeatherForecastError.networkError
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherForecastError.networkError
            }
            
            let decodedValue = try JSONDecoder().decode(T.self, from: data)
            if let arr = decodedValue as? [Any], arr.isEmpty {
                return nil
            }
            return decodedValue
        } catch {
            throw WeatherForecastError.networkError
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
