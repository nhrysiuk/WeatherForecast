import ComposableArchitecture

@Reducer
struct WeatherForecastFeature {
    
    @ObservableState
    struct State {
        var weatherForecastError: WeatherForecastState? = .emptyInput
        var forecasts: [DayForecast] = []
        var cityName: String?
        var isForecastLoading = false
        
        var hasForecasts: Bool {
            !forecasts.isEmpty
        }
    }
    
    enum Action {
        case cityNameEntered(String)
        case forecastResponse([DayForecast])
    }
    
    @Dependency(\.weatherForecast) var weatherForecast
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .cityNameEntered(cityName):
                state.clearForecasts()
                
                guard isCityNameValid(cityName) else {
                    state.weatherForecastError = .emptyInput
                    return .none
                }
                
                state.isForecastLoading = true
                
                return .run { send in
                    let forecasts = try await weatherForecast.fetch(cityName)
                    await send(.forecastResponse(forecasts))
                }
                
            case let .forecastResponse(forecasts):
                state.isForecastLoading = false
                state.forecasts = forecasts
                
                if forecasts.isEmpty {
                    state.weatherForecastError = .incorrectInput
                } else {
                    state.cityName = forecasts.first?.cityName
                }
                
                return .none
            }
        }
    }
    
    private func isCityNameValid(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - State Extensions
extension WeatherForecastFeature.State {
    mutating func clearForecasts() {
        forecasts = []
        cityName = nil
        weatherForecastError = nil
    }
}
