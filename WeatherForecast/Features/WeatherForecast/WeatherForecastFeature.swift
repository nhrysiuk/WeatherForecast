import ComposableArchitecture

@Reducer
struct WeatherForecastFeature {
    
    @ObservableState
    struct State: Equatable {
        var weatherForecastError: WeatherForecastError? = .emptyInput
        var forecasts: [DayForecast] = []
        var cityName: String?
        var isLoading = false
        
        var hasForecasts: Bool {
            !forecasts.isEmpty
        }
        
        var shouldShowEmptyState: Bool {
            !isLoading && !hasForecasts
        }
    }
    
    enum Action {
        case cityNameEntered(String)
        case searchDebounced(String)
        case forecastResponse(Result<[DayForecast], WeatherForecastError>)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.weatherForecast) var weatherForecast
    
    private static let searchFlowCancellationID = "search-flow"
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .cityNameEntered(cityName):
                state.clearState()
                
                if cityName.isEmpty {
                    state.weatherForecastError = .emptyInput
                    state.isLoading = false
                    return .cancel(id: Self.searchFlowCancellationID)
                }
                
                guard isCityNameValid(cityName) else {
                    state.weatherForecastError = .emptyInput
                    return .none
                }
                
                state.isLoading = true
                return .run { send in
                    try await clock.sleep(for: .seconds(0.4))
                    await send(.searchDebounced(cityName))
                }
                .cancellable(id: Self.searchFlowCancellationID, cancelInFlight: true)
                
            case let .searchDebounced(cityName):
                return .run { send in
                    do {
                        let forecasts = try await weatherForecast.fetch(cityName)
                        await send(.forecastResponse(.success(forecasts)))
                    } catch {
                        let weatherError = mapErrorToWeatherError(error)
                        await send(.forecastResponse(.failure(weatherError)))
                    }
                }
                .cancellable(id: Self.searchFlowCancellationID, cancelInFlight: true)
                
            case let .forecastResponse(.success(forecasts)):
                state.isLoading = false
                state.forecasts = forecasts
                
                if forecasts.isEmpty {
                    state.weatherForecastError = .invalidCity
                } else {
                    state.weatherForecastError = nil
                    state.cityName = forecasts.first?.cityName
                }
                
                return .none
                
            case let .forecastResponse(.failure(error)):
                state.isLoading = false
                state.clearState()
                state.weatherForecastError = error
                
                return .none
            }
        }
    }
    
    private func isCityNameValid(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func mapErrorToWeatherError(_ error: Error) -> WeatherForecastError {
        if let weatherError = error as? WeatherForecastError {
            return weatherError
        }
        return .networkError
    }
}

// MARK: - State Extensions
extension WeatherForecastFeature.State {
    mutating func clearState() {
        forecasts = []
        cityName = nil
        weatherForecastError = nil
    }
}

