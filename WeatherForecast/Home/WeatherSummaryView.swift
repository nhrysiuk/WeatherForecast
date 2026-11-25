import Domain
import SwiftUI

struct WeatherSummaryView: View {
    static let placeholder = WeatherSummary(
        temperature: Measurement(value: 10, unit: .celsius),
        minTemperature: Measurement(value: 10, unit: .celsius),
        maxTemperature: Measurement(value: 10, unit: .celsius),
        condition: .clear,
        isDay: true
    )

    let summary: WeatherSummary

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: summary.condition.symbolName(isDay: summary.isDay))
                    .symbolRenderingMode(.hierarchical)
                Text(summary.temperature.formattedTemperature())
            }
            .font(.title3)
            Text(.highLowTemperature(
                summary.maxTemperature.formattedTemperature(),
                summary.minTemperature.formattedTemperature()
            ))
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .monospacedDigit()
    }
}
