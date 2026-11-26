import Domain
import Testing
@testable import WeatherForecast

struct ForecastViewModelTests {
    private let gdansk = City.stub(id: 1, name: "Gdańsk")

    @Test func loadsForecastForCity() async {
        let provider = StubForecastProvider(forecast: .stub())
        let viewModel = ForecastViewModel(city: gdansk, forecastProvider: provider)

        await viewModel.load()

        #expect(viewModel.state == .loaded(.stub()))
        #expect(await provider.requestedForecasts == [gdansk.coordinate])
    }

    @Test(arguments: [WeatherError.offline, .server])
    func showsFailure(error: WeatherError) async {
        let viewModel = ForecastViewModel(city: gdansk, forecastProvider: StubForecastProvider(failures: [error]))

        await viewModel.load()

        #expect(viewModel.state == .failed(error))
    }

    @Test func retriesAfterFailure() async {
        let viewModel = ForecastViewModel(
            city: gdansk,
            forecastProvider: StubForecastProvider(forecast: .stub(), failures: [.offline])
        )
        await viewModel.load()

        await viewModel.load()

        #expect(viewModel.state == .loaded(.stub()))
    }
}
