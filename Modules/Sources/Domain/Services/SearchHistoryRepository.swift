public protocol SearchHistoryRepository: Sendable {
    func load() async throws -> SearchHistory
    func save(_ history: SearchHistory) async throws
}
