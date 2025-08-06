import SwiftUI
import ComposableArchitecture

struct WeatherForecastView: View {
    
    let store: StoreOf<WeatherForecastFeature>
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            searchField
            
            if store.isForecastLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else if store.hasForecasts {
                ForecastListView(forecasts: store.forecasts, cityName: store.cityName)
            } else if let message = store.weatherForecastError?.message {
                EmptyView(message: message)
            }
        }
        .padding()
    }
    
    private var searchField: some View {
        TextField("Enter city name...", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .onChange(of: searchText) { _, newValue in
                store.send(.cityNameEntered(newValue))
            }
    }
}

// MARK: - Forecast List View
private struct ForecastListView: View {
    let forecasts: [DayForecast]
    let cityName: String?
    
    var body: some View {
        VStack(spacing: 16) {
            if let name = cityName {
                Text("Weather forecast for \(name)")
                    .font(.headline)
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(forecasts) { dayForecast in
                        WeatherForecastCellView(dayForecast: dayForecast)
                    }
                }
            }
        }
    }
}
