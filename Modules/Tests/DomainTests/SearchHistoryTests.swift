import Domain
import Testing

struct SearchHistoryTests {
    @Test func startsEmpty() {
        #expect(SearchHistory().cities.isEmpty)
    }

    @Test func putsMostRecentCityFirst() {
        var history = SearchHistory()
        history.record(.stub(id: 1))
        history.record(.stub(id: 2))

        #expect(history.cities.map(\.id) == [2, 1])
    }

    @Test func movesRepeatedCityToTopWithoutDuplicating() {
        var history = SearchHistory(cities: [.stub(id: 3), .stub(id: 2), .stub(id: 1)])
        history.record(.stub(id: 1))

        #expect(history.cities.map(\.id) == [1, 3, 2])
    }

    @Test func keepsLatestDataForRepeatedCity() {
        var history = SearchHistory(cities: [.stub(id: 1, name: "Warsaw")])
        history.record(.stub(id: 1, name: "Warszawa"))

        #expect(history.cities.map(\.name) == ["Warszawa"])
    }

    @Test func dropsOldestCityWhenFull() {
        var history = SearchHistory(cities: [.stub(id: 2), .stub(id: 1)], limit: 2)
        history.record(.stub(id: 3))

        #expect(history.cities.map(\.id) == [3, 2])
    }

    @Test func cleansUpRestoredCities() {
        let restored: [City] = [.stub(id: 1), .stub(id: 2), .stub(id: 1), .stub(id: 3), .stub(id: 4)]
        let history = SearchHistory(cities: restored, limit: 3)

        #expect(history.cities.map(\.id) == [1, 2, 3])
    }
}
