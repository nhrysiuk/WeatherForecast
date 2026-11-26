import Domain
import Testing
@testable import WeatherForecast

struct AppRouterTests {
    private let gdansk = City.stub(id: 1, name: "Gdańsk")
    private let wroclaw = City.stub(id: 2, name: "Wrocław", coordinate: Coordinate(latitude: 51.1, longitude: 17.03))

    @Test func opensForecastAndRecordsCity() async {
        let repository = InMemoryHistoryRepository(SearchHistory(cities: [wroclaw]))
        let store = HistoryStore(repository: repository)
        let router = AppRouter(historyStore: store)

        router.open(gdansk)
        await store.waitForSaves()

        #expect(router.path == [.forecast(gdansk)])
        #expect(store.history.cities == [gdansk, wroclaw])
        #expect(await repository.savedHistories == [SearchHistory(cities: [gdansk, wroclaw])])
    }

    @Test func opensForecastBeforeHistoryFinishesLoading() async {
        let repository = InMemoryHistoryRepository(loadDelay: .milliseconds(50))
        let store = HistoryStore(repository: repository)
        let router = AppRouter(historyStore: store)

        router.open(gdansk)

        #expect(router.path == [.forecast(gdansk)])
        #expect(!store.isLoaded)
        await store.waitForSaves()
    }
}
