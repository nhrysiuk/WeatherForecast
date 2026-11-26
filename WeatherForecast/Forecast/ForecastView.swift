import Domain
import SwiftUI

struct ForecastView: View {
    @State private var viewModel: ForecastViewModel
    @State private var loadAttempt = 0

    init(city: City, forecastProvider: any ForecastProviding) {
        _viewModel = State(initialValue: ForecastViewModel(city: city, forecastProvider: forecastProvider))
    }

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .task(id: loadAttempt) {
                await viewModel.load()
            }
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
            }
            .padding()
        }
    }
}
