import Foundation

// MARK: - Data
struct WeatherForecastData: Codable {
    let list: [Forecast]
}

// MARK: - List
struct Forecast: Codable {
    let main: MainClass
    let weather: [Weather]
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
           case main, weather
           case dtTxt = "dt_txt"
       }
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - MainClass
struct MainClass: Codable {
    let temp: Double
}


// MARK: - Weather
struct Weather: Codable {
    let main: MainEnum
}

enum MainEnum: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
}
