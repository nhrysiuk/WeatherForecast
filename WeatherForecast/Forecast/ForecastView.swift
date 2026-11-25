import Domain
import SwiftUI

struct ForecastView: View {
    @State private var model: ForecastModel
    @State private var loadAttempt = 0

    init(city: City, forecastProvider: any ForecastProviding) {
        _model = State(initialValue: ForecastModel(city: city, forecastProvider: forecastProvider))
    }

    var body: some View {
        content
            .navigationTitle(model.city.name)
            .task(id: loadAttempt) {
                await model.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            layout(current: .placeholder, hourly: .placeholder)
                .skeleton(true)
        case .loaded(let forecast):
            layout(current: CurrentWeatherView(forecast: forecast), hourly: HourlyForecastView(forecast: forecast))
        case .failed(let error):
            ErrorStateView(ErrorStateView.Reason(error)) {
                loadAttempt += 1
            }
        }
    }

    private func layout(current: CurrentWeatherView, hourly: HourlyForecastView) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                current
                hourly
            }
            .padding()
        }
    }
}
