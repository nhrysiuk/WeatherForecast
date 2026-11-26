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

    @ScaledMetric(relativeTo: .largeTitle) private var temperatureSize = 88.0

    var body: some View {
        VStack(spacing: 4) {
            Text(temperature.formattedTemperature())
                .font(.system(size: temperatureSize, weight: .semibold, design: .rounded))
                .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Label {
                Text(condition.localizedName)
            } icon: {
                WeatherSymbol(condition: condition, isDay: isDay)
            }
            .font(.title3.weight(.medium))
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
