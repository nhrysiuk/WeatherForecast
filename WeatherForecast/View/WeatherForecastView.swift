import SwiftUI
import ComposableArchitecture

struct WeatherForecastView: View {
    
    let store: StoreOf<WeatherForecastFeature>
    
    @State private var cityName = ""
    
    var body: some View {
        HStack {
            TextField("Enter city name...", text: self.$cityName)
                .textFieldStyle(.roundedBorder)
                .onChange(of: cityName) {
                    store.send(.cityNameEntered(cityName))
                }
        }
        .padding()
        
        if store.hasForecasts {
            ScrollView {
                LazyVStack {
                    ForEach(store.forecasts) { dayForecast in
                        WeatherForecastCellView(dayForecast: dayForecast)
                    }
                }
            }
            .padding()
        }
        else {
            EmptyView(message: store.weatherForecastState.message)
        }
    }
}
