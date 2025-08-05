import SwiftUI
import ComposableArchitecture

struct WeatherForecastView: View {
    
    let store: StoreOf<WeatherForecastFeature>
    
    @State private var cityName = ""
    
    var body: some View {
        TextField("Enter city name...", text: self.$cityName)
            .textFieldStyle(.roundedBorder)
            .onChange(of: cityName) {
                store.send(.cityNameEntered(cityName))
            }
            .padding()
        
        if store.hasForecasts {
            VStack {
                if let name = store.cityName {
                    Text("Weather forecast for \(name)")
                }
                ScrollView {
                    LazyVStack {
                        ForEach(store.forecasts) { dayForecast in
                            WeatherForecastCellView(dayForecast: dayForecast)
                        }
                    }
                }
                .padding()
            }
        }
        else {
            EmptyView(message: store.weatherForecastState.message)
        }
    }
}
