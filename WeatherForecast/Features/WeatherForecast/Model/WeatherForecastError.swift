import Foundation

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
    
    var uiMessage: (text: String, imageName: String) {
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

