import Domain
import Foundation
import Testing
@testable import WeatherForecast

struct HomeModelTests {
    private let gdansk = City.stub(id: 1, name: "Gdańsk")
    private let wroclaw = City.stub(id: 2, name: "Wrocław", coordinate: Coordinate(latitude: 51.1, longitude: 17.03))
    private let summary = WeatherSummary(
        temperature: Measurement(value: 3, unit: .celsius),
        minTemperature: Measurement(value: -1, unit: .celsius),
        maxTemperature: Measurement(value: 4, unit: .celsius),
        condition: .overcast,
        isDay: true
    )

    @Test func loadsSavedHistory() async {
        let model = makeModel(store: InMemoryHistoryStore(SearchHistory(cities: [gdansk])))

        await model.loadHistory()

        #expect(model.historyState == .loaded)
        #expect(model.history.cities == [gdansk])
    }

    @Test func keepsHistoryInMemoryWhenLoadedAgain() async {
        let model = makeModel(store: InMemoryHistoryStore(SearchHistory(cities: [wroclaw])))
        await model.loadHistory()
        await model.save(gdansk)

        await model.loadHistory()

        #expect(model.history.cities == [gdansk, wroclaw])
    }

    @Test func neverOverwritesHistoryThatFailedToLoad() async {
        let store = InMemoryHistoryStore(loadError: CocoaError(.fileReadCorruptFile))
        let model = makeModel(store: store)

        await model.loadHistory()
        await model.save(gdansk)

        #expect(model.historyState == .failed)
        #expect(await store.savedHistories.isEmpty)
    }

    @Test(arguments: ["", " ", "a"])
    func waitsForAtLeastTwoLetters(query: String) async {
        let model = makeModel(search: .unexpected)
        model.query = query

        await model.search()

        #expect(model.searchState == .idle)
    }

    @Test func rejectsInvalidNameWithoutSearching() async {
        let model = makeModel(search: .unexpected)
        model.query = "Gdańsk 2"

        await model.search()

        #expect(model.searchState == .invalid(.containsDigits))
    }

    @Test func searchesForNormalizedName() async {
        let model = makeModel(search: StubCitySearch { name in
            name == "Gdańsk" ? [City.stub(id: 1, name: "Gdańsk")] : []
        })
        model.query = "  Gdańsk "

        await model.search()

        #expect(model.searchState == .results([gdansk]))
    }

    @Test(arguments: [WeatherError.offline, .server])
    func showsSearchFailure(error: WeatherError) async {
        let model = makeModel(search: StubCitySearch { _ in throw error })
        model.query = "Gdańsk"

        await model.search()

        #expect(model.searchState == .failed(error))
    }

    @Test func savesNewCityOnTop() async {
        let store = InMemoryHistoryStore(SearchHistory(cities: [wroclaw]))
        let model = makeModel(store: store)
        await model.loadHistory()

        await model.save(gdansk)

        #expect(model.history.cities == [gdansk, wroclaw])
        #expect(await store.savedHistories == [SearchHistory(cities: [gdansk, wroclaw])])
    }

    @Test func doesNotSaveWhenHistoryIsFull() async {
        let cities = (1...SearchHistory.limit).map { City.stub(id: 100 + $0) }
        let store = InMemoryHistoryStore(SearchHistory(cities: cities))
        let model = makeModel(store: store)
        await model.loadHistory()

        await model.save(gdansk)

        #expect(model.isHistoryFull)
        #expect(model.history.cities == cities)
        #expect(await store.savedHistories.isEmpty)
    }

    @Test func savesHistoryAfterRemoval() async {
        let store = InMemoryHistoryStore(SearchHistory(cities: [gdansk, wroclaw]))
        let model = makeModel(store: store)
        await model.loadHistory()

        await model.remove(atOffsets: [0])

        #expect(await store.savedHistories == [SearchHistory(cities: [wroclaw])])
    }

    @Test func loadsWeatherOnlyForNewCities() async {
        let provider = StubForecastProvider(summary: summary)
        let model = makeModel(store: InMemoryHistoryStore(SearchHistory(cities: [wroclaw])), forecast: provider)
        await model.loadHistory()
        await model.loadSummaries()

        await model.save(gdansk)
        await model.loadSummaries()
        await model.remove(atOffsets: [0])
        await model.loadSummaries()

        #expect(await provider.requestedCoordinates == [[wroclaw.coordinate], [gdansk.coordinate]])
        #expect(model.summaries == [wroclaw.coordinate: summary, gdansk.coordinate: summary])
    }

    @Test func clearsFailureWhenWeatherLoads() async {
        let provider = StubForecastProvider(summary: summary, failures: [.offline])
        let model = makeModel(store: InMemoryHistoryStore(SearchHistory(cities: [gdansk])), forecast: provider)
        await model.loadHistory()

        await model.loadSummaries()
        #expect(model.summariesFailed)

        await model.loadSummaries()
        #expect(!model.summariesFailed)
        #expect(model.summaries == [gdansk.coordinate: summary])
    }

    private func makeModel(
        search: StubCitySearch = StubCitySearch { _ in [] },
        store: InMemoryHistoryStore = InMemoryHistoryStore(),
        forecast: StubForecastProvider = StubForecastProvider()
    ) -> HomeModel {
        HomeModel(citySearch: search, historyStore: store, forecastProvider: forecast, debounce: .zero)
    }
}
