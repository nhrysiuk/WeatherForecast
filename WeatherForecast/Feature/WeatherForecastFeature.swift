import ComposableArchitecture

@Reducer
struct WeatherForecastFeature {
    
    @ObservableState
    struct State {
        
        var forecasts = [DayForecast]()
        var isShowingForecast = false
        var isForecastLoading = false
        var hasForecasts: Bool {
            !forecasts.isEmpty
        }
    }
    
    enum Action {
        case searchButtonTapped(String)
        case forecastResponse([DayForecast])
    }
    
    @Dependency(\.weatherForecast) var weatherForecast
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchButtonTapped(cityName):
                state.forecasts = []
                state.isForecastLoading = true
                
                return .run { send in
                    try await send(.forecastResponse(weatherForecast.fetch(cityName)))
                }
                
            case let .forecastResponse(forecasts):
                state.isForecastLoading = false
                state.forecasts = forecasts
                state.isShowingForecast = true
                
                return .none
            }
        }
    }
}
