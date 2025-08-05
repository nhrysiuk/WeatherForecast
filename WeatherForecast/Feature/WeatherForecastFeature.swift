import ComposableArchitecture

@Reducer
struct WeatherForecastFeature {
    
    @ObservableState
    struct State {
        var weatherForecastState = WeatherForecastState.emptyInput
        var forecasts = [DayForecast]()
        var hasForecasts: Bool {
            !forecasts.isEmpty
        }
        var cityName: String?
        
        var isForecastLoading = false
    }
    
    enum Action {
        case cityNameEntered(String)
        case incorrectCityName(WeatherForecastState)
        case forecastResponse([DayForecast])
    }
    
    @Dependency(\.weatherForecast) var weatherForecast
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .cityNameEntered(cityName):
                state.forecasts = []
                guard isCityNameValid(cityName) else {
                    return .send(.incorrectCityName(WeatherForecastState.emptyInput))
                }
                state.isForecastLoading = true
                
                return .run { send in
                    try await send(.forecastResponse(weatherForecast.fetch(cityName)))
                }
                
            case let .forecastResponse(forecasts):
                state.isForecastLoading = false
                state.forecasts = forecasts
                guard let firstForecast = forecasts.first else {
                    return .send(.incorrectCityName(WeatherForecastState.incorrectInput))
                }
                state.weatherForecastState = .forecastIsShown
                state.cityName = firstForecast.cityName
                return .none
                
            case let .incorrectCityName(reason):
                state.weatherForecastState = reason
                return .none
            }
        }
    }
    
    func isCityNameValid(_ name: String) -> Bool {
        return !name.isEmpty && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
