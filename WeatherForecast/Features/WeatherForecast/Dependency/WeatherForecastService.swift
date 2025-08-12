import Foundation

struct WeatherForecastService {
    
    private let networkManager: NetworkManager
    private let apiKey: String = "a066f4a8bf5b6cb3985b36c2d99574b8"
    
    init(networkManager: NetworkManager = .init()) {
        self.networkManager = networkManager
    }
    
    func fetchData(cityName: String) async throws -> [DayForecast] {
        let geoURL = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=\(apiKey)")!
        
        let coordinates: [CoordinateData] = try await networkManager.fetch(geoURL)
        
        guard let coordinate = coordinates.first else {
            throw WeatherForecastError.invalidCity
        }
        
        let forecastURL = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)")!
        
        let forecastData: WeatherForecastData = try await networkManager.fetch(forecastURL)
        let filteredData = processForecastData(forecastData, cityName: coordinate.name)
        
        return filteredData
    }
    
    func processForecastData(_ data: WeatherForecastData, cityName: String) -> [DayForecast] {
        return data.list
            .filter { $0.dtTxt.hasSuffix("15:00:00") }
            .map { DayForecast(from: $0, cityName: cityName)}
    }
}
