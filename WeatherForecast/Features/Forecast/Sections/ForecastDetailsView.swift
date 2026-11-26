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

    var body: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                ForecastTile(title: .sunrise, systemImage: "sunrise.fill") {
                    timeValue(sunrise)
                }
                ForecastTile(title: .sunset, systemImage: "sunset.fill") {
                    timeValue(sunset)
                }
            }
            GridRow {
                ForecastTile(title: .feelsLike, systemImage: "thermometer.medium") {
                    value(current.apparentTemperature.formattedTemperature())
                }
                ForecastTile(title: .precipitation, systemImage: "drop.fill") {
                    value(percent(current.precipitationProbability))
                }
            }
            GridRow {
                ForecastTile(title: .visibility, systemImage: "eye.fill") {
                    value(current.visibility.converted(to: .kilometers).formatted(Self.distanceFormat))
                }
                ForecastTile(title: .humidity, systemImage: "humidity.fill") {
                    value(percent(current.relativeHumidity))
                }
            }
            GridRow {
                ForecastTile(title: .wind, systemImage: "wind") {
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
                ForecastTile(title: .uvIndex, systemImage: "sun.max.fill") {
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
        }
        .environment(\.timeZone, timeZone)
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
            Text(date, format: .dateTime.hour().minute())
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
            .font(.system(size: 28))
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
