import Domain
import Foundation

public actor FileSearchHistoryRepository: SearchHistoryRepository {
    public static let defaultFileURL = URL.applicationSupportDirectory.appending(path: "SearchHistory.json")

    private let fileURL: URL

    public init(fileURL: URL = defaultFileURL) {
        self.fileURL = fileURL
    }

    public func load() throws -> SearchHistory {
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            return SearchHistory()
        }
        return try StoredSearchHistory.decode(from: data).makeHistory()
    }

    public func save(_ history: SearchHistory) throws {
        let data = try StoredSearchHistory(history).encoded()
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: .atomic)
    }
}
