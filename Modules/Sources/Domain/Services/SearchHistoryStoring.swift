/// Keeps the search history between app launches.
public protocol SearchHistoryStoring: Sendable {
    /// Returns an empty history when nothing has been saved yet.
    func load() async throws -> SearchHistory
    func save(_ history: SearchHistory) async throws
}
