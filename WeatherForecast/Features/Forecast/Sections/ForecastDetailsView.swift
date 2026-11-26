import Domain
import SwiftUI

struct ForecastDetailsView: View {
    private static let strongGusts = Measurement(value: 60, unit: UnitSpeed.kilometersPerHour)
    private static let sunscreenUVIndex = 3.0

    static let placeholder = ForecastDetailsView(
        current: CurrentConditions(
            temperature: Measurement(value: 10, unit: .celsius),
            apparentTemperature: Measurement(value: 10, unit: .celsius),
            precipitationProbability: 50,
            relativeHumidity: 50,
            visibility: Measurement(value: 10_000, unit: .meters),
            uvIndex: 1,
            wind: Wind(
                speed: Measurement(value: 10, unit: .kilometersPerHour),
                gusts: Measurement(value: 10, unit: .kilometersPerHour),
                direction: Measurement(value: 0, unit: .degrees)
            ),
            condition: .clear,
            isDay: true
        ),
        sunrise: .now,
        sunset: .now,
        timeZone: .current
    )

    let current: CurrentConditions
    let sunrise: Date?
    let sunset: Date?
    let timeZone: TimeZone

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 16) {
                sunriseTile
                sunsetTile
                feelsLikeTile
                precipitationTile
                visibilityTile
                humidityTile
                windTile
                uvIndexTile
            }
        } else {
            Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                GridRow {
                    sunriseTile
                    sunsetTile
                }
                GridRow {
                    feelsLikeTile
                    precipitationTile
                }
                GridRow {
                    visibilityTile
                    humidityTile
                }
                GridRow {
                    windTile
                    uvIndexTile
                }
            }
        }
    }

    private var sunriseTile: some View {
        ForecastTile(title: .sunrise, systemImage: "sunrise.fill", tint: .orange) {
            timeValue(sunrise)
        }
    }

    private var sunsetTile: some View {
        ForecastTile(title: .sunset, systemImage: "sunset.fill", tint: .pink) {
            timeValue(sunset)
        }
    }

    private var feelsLikeTile: some View {
        ForecastTile(title: .feelsLike, systemImage: "thermometer.medium", tint: .red) {
            value(current.apparentTemperature.formattedTemperature())
        }
    }

    private var precipitationTile: some View {
        ForecastTile(title: .precipitationChance, systemImage: "drop.fill", tint: .blue) {
            value(percent(current.precipitationProbability))
        }
    }

    private var visibilityTile: some View {
        ForecastTile(title: .visibility, systemImage: "eye.fill", tint: .purple) {
            value(current.visibility.converted(to: .kilometers).formatted(Self.distanceFormat))
        }
    }

    private var humidityTile: some View {
        ForecastTile(title: .humidity, systemImage: "humidity.fill", tint: .cyan) {
            value(percent(current.relativeHumidity))
        }
    }

    private var windTile: some View {
        ForecastTile(title: .wind, systemImage: "wind", tint: .mint) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    value(current.wind.speed.formatted(Self.speedFormat))
                    gusts
                }
                Spacer(minLength: 4)
                icon("arrow.down.circle.fill")
                    .rotationEffect(.degrees(current.wind.direction.converted(to: .degrees).value))
            }
        }
    }

    private var uvIndexTile: some View {
        ForecastTile(title: .uvIndex, systemImage: "sun.max.fill", tint: .yellow) {
            if let uvIndex = current.uvIndex {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    value(Int(uvIndex.rounded()).formatted())
                    Text(UVLevel(index: uvIndex).localizedName)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                UVIndexBar(index: uvIndex)
                    .padding(.vertical, 6)
                if uvIndex >= Self.sunscreenUVIndex {
                    caption(.uvSunscreen)
                }
            } else {
                value("–")
            }
        }
    }

    @ViewBuilder
    private var gusts: some View {
        let text = Text(.windGusts(current.wind.gusts.formatted(Self.speedFormat)))
        if current.wind.gusts >= Self.strongGusts {
            Label {
                text
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.orange)
        } else {
            text
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private static let speedFormat = Measurement<UnitSpeed>.FormatStyle(
        width: .abbreviated,
        usage: .asProvided,
        numberFormatStyle: .number.precision(.fractionLength(0))
    )
    private static let distanceFormat = Measurement<UnitLength>.FormatStyle(
        width: .abbreviated,
        usage: .asProvided,
        numberFormatStyle: .number.precision(.fractionLength(0...1))
    )

    private func percent(_ value: Int) -> String {
        (Double(value) / 100).formatted(.percent)
    }

    private func value(_ text: String) -> some View {
        Text(text)
            .font(.title2.weight(.medium))
            .monospacedDigit()
            .minimumScaleFactor(0.6)
            .lineLimit(1)
    }

    private func caption(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private func timeValue(_ date: Date?) -> some View {
        if let date {
            Text(date, format: Date.FormatStyle(timeZone: timeZone).hour().minute())
                .font(.title2.weight(.medium))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        } else {
            value("–")
        }
    }

    private func icon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.title)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.secondary)
    }
}

extension ForecastDetailsView {
    init(forecast: Forecast) {
        let today = forecast.daily.first
        self.init(
            current: forecast.current,
            sunrise: today?.sunrise,
            sunset: today?.sunset,
            timeZone: forecast.timeZone
        )
    }
}
