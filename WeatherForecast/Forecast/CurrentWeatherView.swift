import Domain
import SwiftUI

struct CurrentWeatherView: View {
    static let placeholder = CurrentWeatherView(
        temperature: Measurement(value: 10, unit: .celsius),
        condition: .clear,
        isDay: true,
        today: DailyForecast(
            date: .now,
            minTemperature: Measurement(value: 10, unit: .celsius),
            maxTemperature: Measurement(value: 10, unit: .celsius),
            precipitationProbability: 0,
            condition: .clear,
            sunrise: nil,
            sunset: nil
        )
    )

    let temperature: Measurement<UnitTemperature>
    let condition: WeatherCondition
    let isDay: Bool
    let today: DailyForecast?

    var body: some View {
        VStack(spacing: 4) {
            Text(temperature.formattedTemperature())
                .font(.system(size: 80, weight: .semibold))
            Label {
                Text(condition.localizedName)
            } icon: {
                Image(systemName: condition.symbolName(isDay: isDay))
                    .symbolRenderingMode(.hierarchical)
            }
            .font(.title3)
            if let today {
                Text(.highLowTemperature(
                    today.maxTemperature.formattedTemperature(),
                    today.minTemperature.formattedTemperature()
                ))
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
        .monospacedDigit()
        .frame(maxWidth: .infinity)
    }
}

extension CurrentWeatherView {
    init(forecast: Forecast) {
        self.init(
            temperature: forecast.current.temperature,
            condition: forecast.current.condition,
            isDay: forecast.current.isDay,
            today: forecast.daily.first
        )
    }
}
