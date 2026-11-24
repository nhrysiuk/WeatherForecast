import Domain
import Foundation
import Testing

struct SearchHistoryTests {
    @Test func addsNewCityAtTop() {
        var history = SearchHistory(cities: [.stub(id: 1)])

        #expect(history.record(.stub(id: 2)) == .added)
        #expect(history.cities.map(\.id) == [2, 1])
    }

    @Test func keepsPositionAndUpdatesDataOfReopenedCity() {
        var history = SearchHistory(cities: [.stub(id: 2), .stub(id: 1, name: "Warsaw")])

        #expect(history.record(.stub(id: 1, name: "Warszawa")) == .alreadySaved)
        #expect(history.cities.map(\.id) == [2, 1])
        #expect(history.cities.map(\.name) == ["City", "Warszawa"])
    }

    @Test func stopsAddingAtLimitWithoutRemovingAnything() {
        var history = SearchHistory(cities: (1...SearchHistory.limit).map { .stub(id: $0) })
        let saved = history.cities

        #expect(history.record(.stub(id: 100)) == .full)
        #expect(history.cities == saved)
        #expect(history.record(.stub(id: 1)) == .alreadySaved)
    }

    @Test func removesCitiesAtOffsets() {
        var history = SearchHistory(cities: [.stub(id: 1), .stub(id: 2), .stub(id: 3), .stub(id: 4)])

        history.remove(atOffsets: [1, 3])

        #expect(history.cities.map(\.id) == [1, 3])
    }

    @Test(arguments: [
        (source: [0], destination: 3, expected: [2, 3, 1, 4]),
        (source: [3], destination: 0, expected: [4, 1, 2, 3]),
        (source: [0, 2], destination: 4, expected: [2, 4, 1, 3]),
    ])
    func movesCitiesLikeSwiftUIList(source: [Int], destination: Int, expected: [Int]) {
        var history = SearchHistory(cities: [.stub(id: 1), .stub(id: 2), .stub(id: 3), .stub(id: 4)])

        history.move(fromOffsets: IndexSet(source), toOffset: destination)

        #expect(history.cities.map(\.id) == expected)
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
