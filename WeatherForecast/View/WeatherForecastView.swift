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
        
        Spacer()
        
        if !store.forecasts.isEmpty {
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
}

struct WeatherForecastCellView: View {
    
    var dayForecast: DayForecast
    
    var body: some View {
        HStack {
            Image(systemName: dayForecast.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 75, height: 75)
            
            Spacer()
            VStack(spacing: 16) {
                Text(dayForecast.date)
                    .font(.caption)
                Text("\(dayForecast.temperature)°C")
                    .font(.title)
                    .fontWeight(.semibold)
            }
        }
    }
}


#Preview {
    WeatherForecastCellView(dayForecast: DayForecast(date: "15 Aug", temperature: 13.5, imageName: "sun.max.fill"))
}
