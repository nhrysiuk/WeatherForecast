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
}
