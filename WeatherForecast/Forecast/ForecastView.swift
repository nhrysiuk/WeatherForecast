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
            ScrollView {
                CurrentWeatherView.placeholder
                    .padding()
            }
            .skeleton(true)
        case .loaded(let forecast):
            ScrollView {
                CurrentWeatherView(forecast: forecast)
                    .padding()
            }
        case .failed(let error):
            ErrorStateView(ErrorStateView.Reason(error)) {
                loadAttempt += 1
            }
        }
    }
}
