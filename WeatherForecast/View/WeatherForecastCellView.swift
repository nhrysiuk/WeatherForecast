import SwiftUI

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
