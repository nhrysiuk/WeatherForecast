import SwiftUI
import ComposableArchitecture

@main
struct WeatherForecastApp: App {
    
    static let store = Store(initialState: WeatherForecastFeature.State()) {
        WeatherForecastFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            WeatherForecastView(store: WeatherForecastApp.store)
        }
    }
}
