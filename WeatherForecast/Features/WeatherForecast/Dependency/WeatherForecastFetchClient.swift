import Foundation
import ComposableArchitecture

struct WeatherForecastFetchClient {

    var fetch: (String) async throws -> [DayForecast]
}

extension WeatherForecastFetchClient: DependencyKey {
    
    static let liveValue = Self(
        fetch: { cityName in
            try await WeatherForecastService().fetchData(cityName: cityName)
        }
    )
}

extension DependencyValues {
    
    var weatherForecast: WeatherForecastFetchClient {
        get { self[WeatherForecastFetchClient.self] }
        set { self[WeatherForecastFetchClient.self] = newValue }
    }
}
