import Domain
import SwiftUI

struct DailyForecastView: View {
    static let placeholder = DailyForecastView(
        days: (0..<7).map { offset in
            DailyForecast(
                date: Date.now.addingTimeInterval(Double(offset) * 86_400),
                minTemperature: Measurement(value: 0, unit: .celsius),
                maxTemperature: Measurement(value: 10, unit: .celsius),
                precipitationProbability: 0,
                condition: .clear,
                sunrise: nil,
                sunset: nil
            )
        },
        timeZone: .current
    )

    let days: [DailyForecast]
    let timeZone: TimeZone

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ForecastSection(title: .dailyForecastTitle(days.count), systemImage: "calendar", tint: .indigo) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) {
                    ForEach(Array(days.enumerated()), id: \.element.date) { index, day in
                        if index > 0 {
                            Divider()
                        }
                        stackedRow(for: day, isToday: index == 0)
                    }
                }
            } else {
                Grid(horizontalSpacing: 12, verticalSpacing: 10) {
                    ForEach(Array(days.enumerated()), id: \.element.date) { index, day in
                        if index > 0 {
                            Divider()
                        }
                        row(for: day, isToday: index == 0)
                    }
                }
            }
        }
    }

    private var scale: ClosedRange<Double> {
        let lows = days.map { $0.minTemperature.converted(to: .celsius).value }
        let highs = days.map { $0.maxTemperature.converted(to: .celsius).value }
        return (lows.min() ?? 0)...max(highs.max() ?? 0, lows.min() ?? 0)
    }

    private func row(for day: DailyForecast, isToday: Bool) -> some View {
        GridRow {
            dayName(of: day, isToday: isToday)
                .gridColumnAlignment(.leading)
                .frame(minWidth: 56, alignment: .leading)
            VStack(spacing: 2) {
                WeatherSymbol(condition: day.condition, isDay: true)
                precipitation(of: day)
            }
            .frame(minWidth: 32)
            Text(day.minTemperature.formattedTemperature())
                .foregroundStyle(.secondary)
                .gridColumnAlignment(.trailing)
            rangeBar(for: day)
            Text(day.maxTemperature.formattedTemperature())
                .gridColumnAlignment(.trailing)
        }
        .font(.body.weight(.medium))
        .monospacedDigit()
    }

    private func stackedRow(for day: DailyForecast, isToday: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                dayName(of: day, isToday: isToday)
                Spacer(minLength: 8)
                WeatherSymbol(condition: day.condition, isDay: true)
                precipitation(of: day)
            }
            Text(.highLowTemperature(
                day.maxTemperature.formattedTemperature(),
                day.minTemperature.formattedTemperature()
            ))
            .foregroundStyle(.secondary)
            rangeBar(for: day)
        }
        .font(.body.weight(.medium))
        .monospacedDigit()
    }

    @ViewBuilder
    private func dayName(of day: DailyForecast, isToday: Bool) -> some View {
        if isToday {
            Text(.today)
        } else {
            Text(day.date, format: Date.FormatStyle(timeZone: timeZone).weekday(.abbreviated))
        }
    }

    private func precipitation(of day: DailyForecast) -> some View {
        PrecipitationChanceText(probability: day.precipitationProbability)
            .font(.caption.weight(.semibold))
    }

    private func rangeBar(for day: DailyForecast) -> some View {
        TemperatureRangeBar(
            range: day.minTemperature.converted(to: .celsius).value...day.maxTemperature.converted(to: .celsius).value,
            scale: scale
        )
    }
}

extension DailyForecastView {
    init(forecast: Forecast) {
        self.init(days: forecast.daily, timeZone: forecast.timeZone)
    }
}
