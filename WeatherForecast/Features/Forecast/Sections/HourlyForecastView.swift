import Domain
import SwiftUI

struct HourlyForecastView: View {
    static let placeholder = HourlyForecastView(
        hours: (0..<24).map { offset in
            HourlyForecast(
                time: Date.now.addingTimeInterval(Double(offset) * 3600),
                temperature: Measurement(value: 10, unit: .celsius),
                precipitationProbability: 0,
                condition: .clear,
                isDay: true,
                cape: nil,
                liftedIndex: nil
            )
        },
        timeZone: .current,
        currentTemperature: nil
    )

    let hours: [HourlyForecast]
    let timeZone: TimeZone
    let currentTemperature: Measurement<UnitTemperature>?

    var body: some View {
        ForecastSection(title: .hourlyForecastTitle, systemImage: "clock") {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(Array(hours.enumerated()), id: \.element.time) { index, hour in
                        column(for: hour, isNow: index == 0)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .environment(\.timeZone, timeZone)
        }
    }

    private func temperature(of hour: HourlyForecast, isNow: Bool) -> Measurement<UnitTemperature> {
        guard isNow, let currentTemperature else {
            return hour.temperature
        }
        return currentTemperature
    }

    private var hasPrecipitationRow: Bool {
        hours.contains { PrecipitationChanceText.isShown($0.precipitationProbability) }
    }

    private func symbolName(for hour: HourlyForecast) -> String {
        let condition: WeatherCondition = hour.hasThunderstormRisk ? .thunderstorm : hour.condition
        return condition.symbolName(isDay: hour.isDay)
    }

    private func column(for hour: HourlyForecast, isNow: Bool) -> some View {
        VStack(spacing: 8) {
            Group {
                if isNow {
                    Text(.now)
                } else {
                    Text(hour.time, format: .dateTime.hour())
                }
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)
            VStack(spacing: 2) {
                Image(systemName: symbolName(for: hour))
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                    .frame(height: 28)
                PrecipitationChanceText(probability: hour.precipitationProbability)
                    .font(.caption.weight(.semibold))
                    .frame(height: 16)
            }
            .frame(height: hasPrecipitationRow ? 46 : 28)
            Text(temperature(of: hour, isNow: isNow).formattedTemperature())
                .font(.title3)
        }
        .monospacedDigit()
    }
}

extension HourlyForecastView {
    init(forecast: Forecast, now: Date = .now) {
        self.init(
            hours: forecast.upcomingHours(from: now),
            timeZone: forecast.timeZone,
            currentTemperature: forecast.current.temperature
        )
    }
}
