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

    @Environment(\.temperatureScale) private var temperatureScale
    @ScaledMetric(relativeTo: .title3) private var iconHeight = 28.0
    @ScaledMetric(relativeTo: .caption2) private var precipitationHeight = 14.0

    var body: some View {
        ForecastSection(title: .hourlyForecastTitle, systemImage: "clock", tint: .teal) {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(Array(hours.enumerated()), id: \.element.time) { index, hour in
                        column(for: hour, isNow: index == 0)
                    }
                }
                .padding(.top, 4)
            }
            .scrollIndicators(.hidden)
            if hours.contains(where: Self.showsRiskBadge) {
                Label {
                    Text(.thunderstormRiskNote)
                } icon: {
                    Self.riskBadge
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }

    private static var riskBadge: some View {
        Image(systemName: "bolt.fill")
            .foregroundStyle(.orange)
    }

    private static func showsRiskBadge(_ hour: HourlyForecast) -> Bool {
        hour.hasThunderstormRisk && hour.condition != .thunderstorm
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

    private func column(for hour: HourlyForecast, isNow: Bool) -> some View {
        VStack(spacing: 8) {
            Group {
                if isNow {
                    Text(.now)
                } else {
                    Text(hour.time, format: Date.FormatStyle(timeZone: timeZone).hour())
                }
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)
            VStack(spacing: 2) {
                WeatherSymbol(condition: hour.condition, isDay: hour.isDay)
                    .font(.title3)
                    .frame(height: iconHeight)
                    .overlay(alignment: .topTrailing) {
                        if Self.showsRiskBadge(hour) {
                            Self.riskBadge
                                .font(.caption2)
                                .offset(x: 6, y: -4)
                        }
                    }
                PrecipitationChanceText(probability: hour.precipitationProbability)
                    .font(.caption2.weight(.semibold))
                    .frame(height: precipitationHeight)
            }
            .frame(height: hasPrecipitationRow ? iconHeight + precipitationHeight + 2 : iconHeight)
            Text(temperature(of: hour, isNow: isNow).formattedTemperature(scale: temperatureScale))
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
