public protocol SearchHistoryStoring: Sendable {
    func load() async throws -> SearchHistory
    func save(_ history: SearchHistory) async throws
    func discardUnreadableHistory() async throws
}
