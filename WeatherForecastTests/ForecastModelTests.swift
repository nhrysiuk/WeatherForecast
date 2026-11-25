import Domain
import Testing
@testable import WeatherForecast

struct ForecastModelTests {
    private let gdansk = City.stub(id: 1, name: "Gdańsk")

    @Test func loadsForecastForCity() async {
        let provider = StubForecastProvider(forecast: .stub())
        let model = ForecastModel(city: gdansk, forecastProvider: provider)

        await model.load()

        #expect(model.state == .loaded(.stub()))
        #expect(await provider.requestedForecasts == [gdansk.coordinate])
    }

    @Test(arguments: [WeatherError.offline, .server])
    func showsFailure(error: WeatherError) async {
        let model = ForecastModel(city: gdansk, forecastProvider: StubForecastProvider(failures: [error]))

        await model.load()

        #expect(model.state == .failed(error))
    }

    @Test func retriesAfterFailure() async {
        let model = ForecastModel(
            city: gdansk,
            forecastProvider: StubForecastProvider(forecast: .stub(), failures: [.offline])
        )
        await model.load()

        await model.load()

        #expect(model.state == .loaded(.stub()))
    }
}
