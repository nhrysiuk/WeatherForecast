import Domain
import Foundation
import Testing

struct SearchHistoryTests {
    @Test func addsNewCityAtTop() {
        var history = SearchHistory(cities: [.stub(id: 1)])

        history.record(.stub(id: 2))

        #expect(history.cities.map(\.id) == [2, 1])
    }

    @Test func movesReopenedCityToTopWithUpdatedData() {
        var history = SearchHistory(cities: [.stub(id: 2), .stub(id: 1, name: "Warsaw")])

        history.record(.stub(id: 1, name: "Warszawa"))

        #expect(history.cities.map(\.id) == [1, 2])
        #expect(history.cities.map(\.name) == ["Warszawa", "City"])
    }

    @Test func keepsHistoryFullWhenReopeningOldestCity() {
        var history = SearchHistory(cities: (1...SearchHistory.limit).map { .stub(id: $0) })

        history.record(.stub(id: SearchHistory.limit))

        #expect(history.cities.map(\.id) == [SearchHistory.limit] + (1..<SearchHistory.limit))
    }

    @Test func dropsOldestCityAtLimit() {
        var history = SearchHistory(cities: (1...SearchHistory.limit).map { .stub(id: $0) })

        history.record(.stub(id: 100))

        #expect(history.cities.map(\.id) == [100] + (1..<SearchHistory.limit))
    }

    @Test func removesCitiesAtOffsets() {
        var history = SearchHistory(cities: [.stub(id: 1), .stub(id: 2), .stub(id: 3), .stub(id: 4)])

        history.remove(atOffsets: [1, 3])

        #expect(history.cities.map(\.id) == [1, 3])
    }

    @Test func removesDuplicatesFromRestoredCities() {
        let history = SearchHistory(cities: [.stub(id: 1), .stub(id: 2), .stub(id: 1)])

        #expect(history.cities.map(\.id) == [1, 2])
    }

    @Test func keepsRestoredCitiesOverLimit() {
        let restored: [City] = (1...SearchHistory.limit + 1).map { .stub(id: $0) }

        #expect(SearchHistory(cities: restored).cities.count == SearchHistory.limit + 1)
    }
}
