import Domain
import Foundation
import Persistence
import Testing

final class FileSearchHistoryStoreTests {
    private let directory: URL
    private let fileURL: URL
    private let store: FileSearchHistoryStore

    init() {
        directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        fileURL = directory.appending(path: "History/SearchHistory.json")
        store = FileSearchHistoryStore(fileURL: fileURL)
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }

    @Test func returnsEmptyHistoryWhenNothingIsSaved() async throws {
        #expect(try await store.load() == SearchHistory())
    }

    @Test func loadsSavedHistoryInOrder() async throws {
        let history = SearchHistory(cities: [.gdansk, .lviv])

        try await store.save(history)

        #expect(try await store.load() == history)
    }

    @Test func replacesPreviouslySavedHistory() async throws {
        try await store.save(SearchHistory(cities: [.gdansk, .lviv]))

        try await store.save(SearchHistory(cities: [.lviv]))

        #expect(try await store.load() == SearchHistory(cities: [.lviv]))
    }

    @Test func readsVersionOneFormat() async throws {
        try write("""
        {
          "version": 1,
          "cities": [
            {
              "id": 3099434,
              "name": "Gdańsk",
              "region": "Pomerania",
              "countryCode": "PL",
              "latitude": 54.35205,
              "longitude": 18.64637,
              "timeZone": "Europe/Warsaw"
            },
            {
              "id": 702550,
              "name": "Lviv",
              "latitude": 49.83826,
              "longitude": 24.02324,
              "timeZone": "Europe/Kyiv"
            }
          ]
        }
        """)

        #expect(try await store.load() == SearchHistory(cities: [.gdansk, .lviv]))
    }

    @Test func rejectsNewerFormatVersion() async throws {
        try write(#"{"version": 2, "places": []}"#)

        await #expect(throws: SearchHistoryStoreError.unsupportedVersion(2)) {
            try await store.load()
        }
    }

    @Test func rejectsUnreadableFile() async throws {
        try write("not json")

        await #expect(throws: DecodingError.self) {
            try await store.load()
        }
    }

    @Test func discardsUnreadableFileAndStartsEmpty() async throws {
        try write("not json")

        try await store.discardUnreadableHistory()

        #expect(try await store.load() == SearchHistory())
        #expect(!FileManager.default.fileExists(atPath: fileURL.path()))
    }

    @Test func discardingWithoutSavedFileSucceeds() async throws {
        try await store.discardUnreadableHistory()

        #expect(try await store.load() == SearchHistory())
    }

    private func write(_ json: String) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data(json.utf8).write(to: fileURL)
    }
}

private extension City {
    static let gdansk = City(
        id: 3099434,
        name: "Gdańsk",
        region: "Pomerania",
        countryCode: "PL",
        coordinate: Coordinate(latitude: 54.35205, longitude: 18.64637)
    )

    static let lviv = City(
        id: 702550,
        name: "Lviv",
        region: nil,
        countryCode: nil,
        coordinate: Coordinate(latitude: 49.83826, longitude: 24.02324)
    )
}
