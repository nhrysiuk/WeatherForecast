import SwiftUI
import ComposableArchitecture

struct WeatherForecastView: View {
    
    let store: StoreOf<WeatherForecastFeature>
    
    @State private var cityName = ""
    
    var body: some View {
        HStack {
            TextField("Enter city name...", text: self.$cityName)
                .textFieldStyle(.roundedBorder)
            Button {
                store.send(.searchButtonTapped(cityName))
            } label: {
                Image(systemName: "magnifyingglass.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .tint(Color.brown)
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
            EmptyView(messageText: EmptyViewNames.noForecastFound)
        }
    }
}
