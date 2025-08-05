enum WeatherForecastState {
    
    case forecastIsShown
    case incorrectInput
    case emptyInput
    
    var message: (String, String) {
        switch self {
        case .incorrectInput:
            ("Oops! We don’t have any forecast for that city. Double-check the name and try again.", "exclamationmark.warninglight.fill")
        case .emptyInput:
            ("Enter city name to see the forecast.", "pencil.line")
        case .forecastIsShown:
            ("", "")
        }
    }
}
