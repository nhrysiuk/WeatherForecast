import Foundation

struct DayForecast: Hashable, Identifiable {
    let id = UUID()
    
    let date: String
    let temperature: Int
    let imageName: String
    
    init(from data: Forecast) {
        temperature = Int(data.main.temp - 273.15)
        date = DateFormatter.formatDate(data.dtTxt) ?? ""
        imageName = switch data.weather[0].main {
        case .clear:
            "sun.max.fill"
        case .clouds:
            "cloud.fill"
        case .rain:
            "cloud.rain.fill"
        }
    }
    
    init(date: String, temperature: Double, imageName: String) {
        self.date = date
        self.temperature = Int(temperature)
        self.imageName = imageName
    }
}
