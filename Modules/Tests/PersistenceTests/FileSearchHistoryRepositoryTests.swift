import Domain
import Foundation
import Persistence
import Testing

final class FileSearchHistoryRepositoryTests {
    private let directory: URL
    private let fileURL: URL
    private let repository: FileSearchHistoryRepository

    init() {
        directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        fileURL = directory.appending(path: "History/SearchHistory.json")
        repository = FileSearchHistoryRepository(fileURL: fileURL)
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }

    @Test func returnsEmptyHistoryWhenNothingIsSaved() async throws {
        #expect(try await repository.load() == SearchHistory())
    }

    @Test func loadsSavedHistoryInOrder() async throws {
        let history = SearchHistory(cities: [.gdansk, .lviv])

        try await repository.save(history)

        #expect(try await repository.load() == history)
    }

    @Test func replacesPreviouslySavedHistory() async throws {
        try await repository.save(SearchHistory(cities: [.gdansk, .lviv]))

        try await repository.save(SearchHistory(cities: [.lviv]))

        #expect(try await repository.load() == SearchHistory(cities: [.lviv]))
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

        #expect(try await repository.load() == SearchHistory(cities: [.gdansk, .lviv]))
    }

    @Test func rejectsNewerFormatVersion() async throws {
        try write(#"{"version": 2, "places": []}"#)

        await #expect(throws: SearchHistoryRepositoryError.unsupportedVersion(2)) {
            try await repository.load()
        }
    }

    @Test func rejectsUnreadableFile() async throws {
        try write("not json")

        await #expect(throws: DecodingError.self) {
            try await repository.load()
        }
    }

    @Test func savingReplacesUnreadableFile() async throws {
        try write("not json")

        try await repository.save(SearchHistory(cities: [.gdansk]))

        #expect(try await repository.load() == SearchHistory(cities: [.gdansk]))
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
