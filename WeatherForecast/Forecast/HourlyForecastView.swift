import Domain
import SwiftUI

struct HourlyForecastView: View {
    private static let shownPrecipitationProbability = 20

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
            if hours.contains(where: \.hasThunderstormRisk) {
                Label(.thunderstormRisk, systemImage: "bolt.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private static func showsPrecipitation(_ hour: HourlyForecast) -> Bool {
        hour.precipitationProbability >= shownPrecipitationProbability
    }

    private static func hasExtras(_ hour: HourlyForecast) -> Bool {
        hour.hasThunderstormRisk || showsPrecipitation(hour)
    }

    private func temperature(of hour: HourlyForecast, isNow: Bool) -> Measurement<UnitTemperature> {
        guard isNow, let currentTemperature else {
            return hour.temperature
        }
        return currentTemperature
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
            Text(temperature(of: hour, isNow: isNow).formattedTemperature())
                .font(.title3)
            if hours.contains(where: Self.hasExtras) {
                HStack(spacing: 2) {
                    if hour.hasThunderstormRisk {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.yellow)
                    }
                    if Self.showsPrecipitation(hour) {
                        Text(Double(hour.precipitationProbability) / 100, format: .percent)
                            .foregroundStyle(.blue)
                    }
                }
                .font(.caption.weight(.semibold))
                .frame(minHeight: 16)
            }
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
