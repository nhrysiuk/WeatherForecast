import Domain
import Foundation
import Testing
@testable import WeatherForecast

struct HomeViewModelTests {
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
        let viewModel = makeModel(store: InMemoryHistoryStore(SearchHistory(cities: [gdansk])))

        await viewModel.loadHistory()

        #expect(viewModel.historyState == .loaded)
        #expect(viewModel.history.cities == [gdansk])
    }

    @Test func keepsHistoryInMemoryWhenLoadedAgain() async {
        let viewModel = makeModel(store: InMemoryHistoryStore(SearchHistory(cities: [wroclaw])))
        await viewModel.loadHistory()
        await viewModel.save(gdansk)

        await viewModel.loadHistory()

        #expect(viewModel.history.cities == [gdansk, wroclaw])
    }

    @Test func startsEmptyWhenHistoryIsUnreadable() async {
        let store = InMemoryHistoryStore(loadError: CocoaError(.fileReadCorruptFile))
        let viewModel = makeModel(store: store)

        await viewModel.loadHistory()
        await viewModel.save(gdansk)

        #expect(viewModel.historyState == .loaded)
        #expect(await store.savedHistories == [SearchHistory(cities: [gdansk])])
    }

    @Test(arguments: ["", " ", "a"])
    func waitsForAtLeastTwoLetters(query: String) async {
        let viewModel = makeModel(search: .unexpected)
        viewModel.query = query

        await viewModel.search()

        #expect(viewModel.searchState == .idle)
    }

    @Test func rejectsInvalidNameWithoutSearching() async {
        let viewModel = makeModel(search: .unexpected)
        viewModel.query = "Gdańsk 2"

        await viewModel.search()

        #expect(viewModel.searchState == .invalid(.containsDigits))
    }

    @Test func searchesForNormalizedName() async {
        let viewModel = makeModel(search: StubCitySearch { name in
            name == "Gdańsk" ? [City.stub(id: 1, name: "Gdańsk")] : []
        })
        viewModel.query = "  Gdańsk "

        await viewModel.search()

        #expect(viewModel.searchState == .results([gdansk]))
    }

    @Test(arguments: [WeatherError.offline, .server])
    func showsSearchFailure(error: WeatherError) async {
        let viewModel = makeModel(search: StubCitySearch { _ in throw error })
        viewModel.query = "Gdańsk"

        await viewModel.search()

        #expect(viewModel.searchState == .failed(error))
    }

    @Test func ignoresResultsOfCancelledSearch() async {
        let (started, startedContinuation) = AsyncStream<Void>.makeStream()
        let (release, releaseContinuation) = AsyncStream<Void>.makeStream()
        let viewModel = makeModel(search: StubCitySearch { _ in
            startedContinuation.yield()
            for await _ in release {}
            return [City.stub(id: 1, name: "Gdańsk")]
        })
        viewModel.query = "Gdańsk"
        let search = Task { await viewModel.search() }
        var startedIterator = started.makeAsyncIterator()
        await startedIterator.next()

        search.cancel()
        await search.value
        releaseContinuation.finish()

        #expect(viewModel.searchState == .loading)
    }

    @Test func ignoresFailureOfCancelledSearch() async {
        let (started, startedContinuation) = AsyncStream<Void>.makeStream()
        let (release, releaseContinuation) = AsyncStream<Void>.makeStream()
        let viewModel = makeModel(search: StubCitySearch { _ in
            startedContinuation.yield()
            for await _ in release {}
            throw WeatherError.server
        })
        viewModel.query = "Gdańsk"
        let search = Task { await viewModel.search() }
        var startedIterator = started.makeAsyncIterator()
        await startedIterator.next()

        search.cancel()
        await search.value
        releaseContinuation.finish()

        #expect(viewModel.searchState == .loading)
    }

    @Test func savesNewCityOnTop() async {
        let store = InMemoryHistoryStore(SearchHistory(cities: [wroclaw]))
        let viewModel = makeModel(store: store)
        await viewModel.loadHistory()

        await viewModel.save(gdansk)

        #expect(viewModel.history.cities == [gdansk, wroclaw])
        #expect(await store.savedHistories == [SearchHistory(cities: [gdansk, wroclaw])])
    }

    @Test func dropsOldestCityWhenHistoryIsFull() async {
        let cities = (1...SearchHistory.limit).map { City.stub(id: 100 + $0) }
        let store = InMemoryHistoryStore(SearchHistory(cities: cities))
        let viewModel = makeModel(store: store)
        await viewModel.loadHistory()

        await viewModel.save(gdansk)

        let expected = SearchHistory(cities: [gdansk] + cities.dropLast())
        #expect(viewModel.history == expected)
        #expect(await store.savedHistories == [expected])
    }

    @Test func savesHistoryAfterRemoval() async {
        let store = InMemoryHistoryStore(SearchHistory(cities: [gdansk, wroclaw]))
        let viewModel = makeModel(store: store)
        await viewModel.loadHistory()

        await viewModel.remove(atOffsets: [0])

        #expect(await store.savedHistories == [SearchHistory(cities: [wroclaw])])
    }

    @Test func loadsWeatherOnlyForNewCities() async {
        let provider = StubForecastProvider(summary: summary)
        let viewModel = makeModel(store: InMemoryHistoryStore(SearchHistory(cities: [wroclaw])), forecast: provider)
        await viewModel.loadHistory()
        await viewModel.loadSummaries()

        await viewModel.save(gdansk)
        await viewModel.loadSummaries()
        await viewModel.remove(atOffsets: [0])
        await viewModel.loadSummaries()

        #expect(await provider.requestedCoordinates == [[wroclaw.coordinate], [gdansk.coordinate]])
        #expect(viewModel.summaries == [wroclaw.coordinate: summary, gdansk.coordinate: summary])
    }

    @Test func clearsFailureWhenWeatherLoads() async {
        let provider = StubForecastProvider(summary: summary, failures: [.offline])
        let viewModel = makeModel(store: InMemoryHistoryStore(SearchHistory(cities: [gdansk])), forecast: provider)
        await viewModel.loadHistory()

        await viewModel.loadSummaries()
        #expect(viewModel.summariesFailed)

        await viewModel.loadSummaries()
        #expect(!viewModel.summariesFailed)
        #expect(viewModel.summaries == [gdansk.coordinate: summary])
    }

    private func makeModel(
        search: StubCitySearch = StubCitySearch { _ in [] },
        store: InMemoryHistoryStore = InMemoryHistoryStore(),
        forecast: StubForecastProvider = StubForecastProvider()
    ) -> HomeViewModel {
        HomeViewModel(citySearch: search, historyStore: store, forecastProvider: forecast, debounce: .zero)
    }
}
