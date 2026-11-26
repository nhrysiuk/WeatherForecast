import Domain
import Foundation
import Testing
@testable import WeatherForecast

struct HistoryViewModelTests {
    private let gdansk = City.stub(id: 1, name: "Gdańsk")
    private let wroclaw = City.stub(id: 2, name: "Wrocław", coordinate: Coordinate(latitude: 51.1, longitude: 17.03))
    private let summary = WeatherSummary(
        temperature: Measurement(value: 3, unit: .celsius),
        minTemperature: Measurement(value: -1, unit: .celsius),
        maxTemperature: Measurement(value: 4, unit: .celsius),
        condition: .overcast,
        isDay: true
    )

    @Test func loadsWeatherOnlyForNewCities() async {
        let provider = StubForecastProvider(summary: summary)
        let viewModel = HistoryViewModel(forecastProvider: provider)
        await viewModel.loadSummaries(for: [wroclaw.coordinate])

        await viewModel.loadSummaries(for: [gdansk.coordinate, wroclaw.coordinate])
        await viewModel.loadSummaries(for: [wroclaw.coordinate])

        #expect(await provider.requestedCoordinates == [[wroclaw.coordinate], [gdansk.coordinate]])
        #expect(viewModel.summaries == [wroclaw.coordinate: summary, gdansk.coordinate: summary])
    }

    @Test func clearsFailureWhenWeatherLoads() async {
        let provider = StubForecastProvider(summary: summary, failures: [.offline])
        let viewModel = HistoryViewModel(forecastProvider: provider)

        await viewModel.loadSummaries(for: [gdansk.coordinate])
        #expect(viewModel.summariesFailed)

        await viewModel.loadSummaries(for: [gdansk.coordinate])
        #expect(!viewModel.summariesFailed)
        #expect(viewModel.summaries == [gdansk.coordinate: summary])
    }
}
