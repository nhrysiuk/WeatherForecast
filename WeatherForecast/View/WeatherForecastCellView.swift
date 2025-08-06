import SwiftUI

struct WeatherForecastCellView: View {
    
    let dayForecast: DayForecast
    
    var body: some View {
        HStack(spacing: 16) {
            weatherIcon
            
            Spacer()
            
            VStack(spacing: 8) {
                Text(dayForecast.date)
                    .font(.caption)
                Text("\(dayForecast.temperature)°C")
                    .font(.title)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var weatherIcon: some View {
        Image(systemName: dayForecast.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
            .foregroundStyle(.blue)
    }
}
