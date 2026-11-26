import Domain
import Foundation
import Testing
@testable import WeatherForecast

struct HistoryStoreTests {
    private let gdansk = City.stub(id: 1, name: "Gdańsk")
    private let wroclaw = City.stub(id: 2, name: "Wrocław", coordinate: Coordinate(latitude: 51.1, longitude: 17.03))

    @Test func loadsSavedHistory() async {
        let store = HistoryStore(repository: InMemoryHistoryRepository(SearchHistory(cities: [gdansk])))

        await store.load()

        #expect(store.isLoaded)
        #expect(store.history.cities == [gdansk])
    }

    @Test func readsFileOnlyOnce() async {
        let repository = InMemoryHistoryRepository(SearchHistory(cities: [wroclaw]))
        let store = HistoryStore(repository: repository)
        await store.load()
        store.record(gdansk)
        await store.waitForSaves()

        await store.load()

        #expect(store.history.cities == [gdansk, wroclaw])
        #expect(await repository.loadCount == 1)
    }

    @Test func startsEmptyWhenHistoryIsUnreadable() async {
        let repository = InMemoryHistoryRepository(loadError: CocoaError(.fileReadCorruptFile))
        let store = HistoryStore(repository: repository)

        await store.load()
        store.record(gdansk)
        await store.waitForSaves()

        #expect(store.isLoaded)
        #expect(await repository.savedHistories == [SearchHistory(cities: [gdansk])])
    }

    @Test func keepsCityRecordedWhileLoading() async {
        let repository = InMemoryHistoryRepository(SearchHistory(cities: [wroclaw]), loadDelay: .milliseconds(50))
        let store = HistoryStore(repository: repository)
        let loading = Task { await store.load() }

        store.record(gdansk)
        await loading.value
        await store.waitForSaves()

        #expect(store.history.cities == [gdansk, wroclaw])
        #expect(await repository.loadCount == 1)
    }

    @Test func keepsOrderOfCitiesRecordedWhileLoading() async {
        let repository = InMemoryHistoryRepository(loadDelay: .milliseconds(50))
        let store = HistoryStore(repository: repository)

        store.record(wroclaw)
        store.record(gdansk)
        await store.waitForSaves()

        #expect(store.history.cities == [gdansk, wroclaw])
        #expect(await repository.savedHistories.last == SearchHistory(cities: [gdansk, wroclaw]))
    }

    @Test func recordsNewCityOnTop() async {
        let repository = InMemoryHistoryRepository(SearchHistory(cities: [wroclaw]))
        let store = HistoryStore(repository: repository)

        store.record(gdansk)
        await store.waitForSaves()

        #expect(store.history.cities == [gdansk, wroclaw])
        #expect(await repository.savedHistories == [SearchHistory(cities: [gdansk, wroclaw])])
    }

    @Test func dropsOldestCityWhenHistoryIsFull() async {
        let cities = (1...SearchHistory.limit).map { City.stub(id: 100 + $0) }
        let repository = InMemoryHistoryRepository(SearchHistory(cities: cities))
        let store = HistoryStore(repository: repository)

        store.record(gdansk)
        await store.waitForSaves()

        let expected = SearchHistory(cities: [gdansk] + cities.dropLast())
        #expect(store.history == expected)
        #expect(await repository.savedHistories == [expected])
    }

    @Test func savesHistoryAfterRemoval() async {
        let repository = InMemoryHistoryRepository(SearchHistory(cities: [gdansk, wroclaw]))
        let store = HistoryStore(repository: repository)
        await store.load()

        store.remove(atOffsets: [0])
        await store.waitForSaves()

        #expect(store.history.cities == [wroclaw])
        #expect(await repository.savedHistories == [SearchHistory(cities: [wroclaw])])
    }

    @Test func skipsSavingWhenNothingChanged() async {
        let repository = InMemoryHistoryRepository(SearchHistory(cities: [gdansk]))
        let store = HistoryStore(repository: repository)

        store.record(gdansk)
        await store.waitForSaves()

        #expect(await repository.savedHistories.isEmpty)
    }

    @Test func savesChangesInOrderWhenEarlierSaveIsSlow() async {
        let repository = InMemoryHistoryRepository(SearchHistory(cities: [gdansk]), saveDelays: [.milliseconds(50), .zero])
        let store = HistoryStore(repository: repository)
        await store.load()

        store.remove(atOffsets: [0])
        store.record(wroclaw)
        await store.waitForSaves()

        #expect(await repository.savedHistories == [SearchHistory(), SearchHistory(cities: [wroclaw])])
    }
}
