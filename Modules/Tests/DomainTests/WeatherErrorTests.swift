import Domain
import Testing

struct WeatherErrorTests {
    private struct UnknownError: Error {}

    @Test(arguments: [WeatherError.offline, .server])
    func keepsWeatherError(_ error: WeatherError) {
        #expect(WeatherError(error) == error)
    }

    @Test func treatsOtherErrorsAsServerError() {
        #expect(WeatherError(UnknownError()) == .server)
    }
}
