import SwiftUI
import ComposableArchitecture

struct WeatherForecastView: View {
    
    let store: StoreOf<WeatherForecastFeature>
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            searchField
            
            if store.isLoading {
                loadingView
            } else if store.hasForecasts {
                ForecastListView(forecasts: store.forecasts, cityName: store.cityName)
            } else if store.shouldShowEmptyState, let error = store.weatherForecastError {
                EmptyView(message: error.uiMessage)
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
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Fetching weather data...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
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
