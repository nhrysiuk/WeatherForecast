import Domain
import SwiftUI

struct ForecastView: View {
    @State private var viewModel: ForecastViewModel
    @State private var loadAttempt = 0
    @AppStorage(TemperatureScale.storageKey) private var temperatureScale = TemperatureScale(locale: .autoupdatingCurrent)

    private static let maximumContentWidth: CGFloat = 640
    private static let attributionURL = URL(string: "https://open-meteo.com")!

    init(city: City, forecastProvider: any ForecastProviding) {
        _viewModel = State(initialValue: ForecastViewModel(city: city, forecastProvider: forecastProvider))
    }

    var body: some View {
        content
            .fontDesign(.rounded)
            .background {
                WeatherBackground(style: backgroundStyle)
            }
            .environment(\.timeZone, timeZone)
            .environment(\.temperatureScale, temperatureScale)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(.temperatureUnit, selection: $temperatureScale) {
                            ForEach(TemperatureScale.allCases) { scale in
                                Text(scale.name)
                            }
                        }
                    } label: {
                        Text(verbatim: temperatureScale.unit.symbol)
                    }
                    .navigationBarItemTint()
                }
            }
            .task(id: loadAttempt) {
                await viewModel.load()
            }
    }

    private var timeZone: TimeZone {
        guard case .loaded(let forecast) = viewModel.state else {
            return .current
        }
        return forecast.timeZone
    }

    private var backgroundStyle: WeatherBackgroundStyle {
        guard case .loaded(let forecast) = viewModel.state else {
            return .neutral
        }
        return WeatherBackgroundStyle(forecast: forecast)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            layout(
                current: .placeholder,
                hourly: .placeholder,
                daily: .placeholder,
                details: .placeholder,
                isLoading: true
            )
        case .loaded(let forecast):
            layout(
                current: CurrentWeatherView(forecast: forecast),
                hourly: HourlyForecastView(forecast: forecast),
                daily: DailyForecastView(forecast: forecast),
                details: ForecastDetailsView(forecast: forecast),
                isLoading: false
            )
        case .failed(let error):
            ErrorStateView(reason: .init(error)) {
                loadAttempt += 1
            }
        }
    }

    private func layout(
        current: CurrentWeatherView,
        hourly: HourlyForecastView,
        daily: DailyForecastView,
        details: ForecastDetailsView,
        isLoading: Bool
    ) -> some View {
        ScrollView {
            VStack(spacing: 4) {
                Text(viewModel.city.name)
                    .font(.title2.weight(.medium))
                    .multilineTextAlignment(.center)
                VStack(spacing: 16) {
                    current
                        .padding(.bottom, 8)
                    hourly
                    daily
                    details
                }
                .skeleton(isLoading)
                Link(destination: Self.attributionURL) {
                    Text(.weatherDataAttribution)
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 16)
            }
            .padding()
            .frame(maxWidth: Self.maximumContentWidth)
            .frame(maxWidth: .infinity)
        }
    }
}
