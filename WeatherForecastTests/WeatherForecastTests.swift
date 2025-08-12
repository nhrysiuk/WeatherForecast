import ComposableArchitecture
import Testing

@testable import WeatherForecast

@MainActor
struct WeatherForecastFeatureTest {
    
    @Test func testSuccessResponse() async {
        let clock = TestClock()
        
        let store = TestStore(initialState: WeatherForecastFeature.State()) {
            WeatherForecastFeature()
        } withDependencies: {
            $0.weatherForecast.fetch = { _ in DayForecast.mockDays }
            $0.continuousClock = clock
        }
        
        await store.send(.cityNameEntered("k")) { state in
            state.isLoading = true
            state.weatherForecastError = nil
        }
        
        await clock.advance(by: .seconds(0.4))
        
        await store.receive(\.searchDebounced)
        await store.receive(\.forecastResponse.success) { state in
            state.isLoading = false
            state.cityName = "Kyiv"
            state.forecasts = DayForecast.mockDays
        }
    }
    
    @Test func testNoForecastFoundResponse() async {
        let clock = TestClock()
        
        let store = TestStore(initialState: WeatherForecastFeature.State()) {
            WeatherForecastFeature()
        } withDependencies: {
            $0.weatherForecast.fetch = { _ in [] }
            $0.continuousClock = clock
        }
        
        await store.send(.cityNameEntered("k")) { state in
            state.isLoading = true
            state.forecasts = []
            state.weatherForecastError = nil
        }
        
        await clock.advance(by: .seconds(0.4))
        
        await store.receive(\.searchDebounced)
        await store.receive(\.forecastResponse.success) { state in
            state.weatherForecastError = .invalidCity
            state.isLoading = false
            state.forecasts = []
        }
    }
    
    @Test func testRequestWithSpaceInput() async {
        let clock = TestClock()
        
        let store = TestStore(initialState: WeatherForecastFeature.State()) {
            WeatherForecastFeature()
        } withDependencies: {
            $0.weatherForecast.fetch = { _ in DayForecast.mockDays }
            $0.continuousClock = clock
        }
        
        await store.send(.cityNameEntered(" "))
    }
    
    @Test func testFewResponses() async {
        let clock = TestClock()
        
        let store = TestStore(initialState: WeatherForecastFeature.State()) {
            WeatherForecastFeature()
        } withDependencies: {
            $0.weatherForecast.fetch = { _ in [] }
            $0.continuousClock = clock
        }
        
        await store.send(.cityNameEntered("k")) { state in
            state.isLoading = true
            state.forecasts = []
            state.weatherForecastError = nil
        }
        
        await store.send(.cityNameEntered("")) { state in
            state.isLoading = false
            state.forecasts = []
            state.weatherForecastError = .emptyInput
        }
    }
    
    @Test func testForecastResponseFailure() async {
        let clock = TestClock()

        let store = TestStore(initialState: WeatherForecastFeature.State()) {
            WeatherForecastFeature()
        } withDependencies: {
            $0.weatherForecast.fetch = { _ in throw WeatherForecastError.networkError }
            $0.continuousClock = clock
        }

        await store.send(.cityNameEntered("k")) { state in
            state.isLoading = true
            state.weatherForecastError = nil
        }

        await clock.advance(by: .seconds(0.4))

        await store.receive(\.searchDebounced)

        await store.receive(\.forecastResponse.failure) { state in
            state.isLoading = false
            state.weatherForecastError = .networkError
            state.forecasts = []
            state.cityName = nil
        }
    }
}
