import Domain

actor InMemoryHistoryStore: SearchHistoryStoring {
    private let loadResult: Result<SearchHistory, any Error>
    private(set) var savedHistories: [SearchHistory] = []

    init(_ history: SearchHistory = SearchHistory()) {
        loadResult = .success(history)
    }

    init(loadError: any Error) {
        loadResult = .failure(loadError)
    }

    func load() throws -> SearchHistory {
        try loadResult.get()
    }

    func save(_ history: SearchHistory) {
        savedHistories.append(history)
    }
}
