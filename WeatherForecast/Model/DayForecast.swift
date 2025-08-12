import Foundation

struct DayForecast: Hashable, Identifiable {
    let id = UUID()
    
    var cityName: String
    let date: String
    let temperature: Int
    let imageName: String
    
    init(from data: Forecast, cityName: String) {
        self.temperature = Int(data.main.temp - 273.15)
        self.date = DateFormatter.formatDate(data.dtTxt) ?? ""
        self.cityName = cityName
        self.imageName = switch data.weather[0].main {
        case .clear:
            "sun.max.fill"
        case .clouds:
            "cloud.fill"
        case .rain:
            "cloud.rain.fill"
        }
    }
    
    init(cityName: String, date: String, temperature: Int, imageName: String) {
        self.cityName = cityName
        self.date = date
        self.temperature = temperature
        self.imageName = imageName
    }
    
    static let mockDays: [DayForecast] = [DayForecast(cityName: "Kyiv", date: "05.05.2001", temperature: 23, imageName: "sun.max.fill")]
}
