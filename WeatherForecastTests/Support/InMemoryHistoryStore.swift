import Domain

actor InMemoryHistoryStore: SearchHistoryStoring {
    private var loadResult: Result<SearchHistory, any Error>
    private let discardError: (any Error)?
    private(set) var savedHistories: [SearchHistory] = []
    private(set) var discardCount = 0

    init(_ history: SearchHistory = SearchHistory()) {
        loadResult = .success(history)
        discardError = nil
    }

    init(loadError: any Error, discardError: (any Error)? = nil) {
        loadResult = .failure(loadError)
        self.discardError = discardError
    }

    func load() throws -> SearchHistory {
        try loadResult.get()
    }

    func save(_ history: SearchHistory) {
        savedHistories.append(history)
    }

    func discardUnreadableHistory() throws {
        if let discardError {
            throw discardError
        }
        discardCount += 1
        loadResult = .success(SearchHistory())
    }
}
