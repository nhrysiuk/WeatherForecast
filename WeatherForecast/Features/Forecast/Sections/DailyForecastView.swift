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

    var body: some View {
        ForecastSection(title: .dailyForecastTitle(days.count), systemImage: "calendar") {
            Grid(horizontalSpacing: 12, verticalSpacing: 10) {
                ForEach(Array(days.enumerated()), id: \.element.date) { index, day in
                    if index > 0 {
                        Divider()
                    }
                    row(for: day, isToday: index == 0)
                }
            }
            .environment(\.timeZone, timeZone)
        }
    }

    private var scale: ClosedRange<Double> {
        let lows = days.map { $0.minTemperature.converted(to: .celsius).value }
        let highs = days.map { $0.maxTemperature.converted(to: .celsius).value }
        return (lows.min() ?? 0)...max(highs.max() ?? 0, lows.min() ?? 0)
    }

    private func row(for day: DailyForecast, isToday: Bool) -> some View {
        GridRow {
            Group {
                if isToday {
                    Text(.today)
                } else {
                    Text(day.date, format: .dateTime.weekday(.abbreviated))
                }
            }
            .gridColumnAlignment(.leading)
            .frame(minWidth: 56, alignment: .leading)
            VStack(spacing: 2) {
                Image(systemName: day.condition.symbolName(isDay: true))
                    .symbolRenderingMode(.hierarchical)
                PrecipitationChanceText(probability: day.precipitationProbability)
                    .font(.caption.weight(.semibold))
            }
            .frame(minWidth: 32)
            Text(day.minTemperature.formattedTemperature())
                .foregroundStyle(.secondary)
                .gridColumnAlignment(.trailing)
            TemperatureRangeBar(
                range: day.minTemperature.converted(to: .celsius).value...day.maxTemperature.converted(to: .celsius).value,
                scale: scale
            )
            Text(day.maxTemperature.formattedTemperature())
                .gridColumnAlignment(.trailing)
        }
        .font(.body.weight(.medium))
        .monospacedDigit()
    }
}

extension DailyForecastView {
    init(forecast: Forecast) {
        self.init(days: forecast.daily, timeZone: forecast.timeZone)
    }
}
