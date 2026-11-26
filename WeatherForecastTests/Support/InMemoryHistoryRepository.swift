import Domain

actor InMemoryHistoryRepository: SearchHistoryRepository {
    private let loadResult: Result<SearchHistory, any Error>
    private let loadDelay: Duration
    private var saveDelays: [Duration]
    private(set) var loadCount = 0
    private(set) var savedHistories: [SearchHistory] = []

    init(_ history: SearchHistory = SearchHistory(), loadDelay: Duration = .zero, saveDelays: [Duration] = []) {
        loadResult = .success(history)
        self.loadDelay = loadDelay
        self.saveDelays = saveDelays
    }

    init(loadError: any Error) {
        loadResult = .failure(loadError)
        loadDelay = .zero
        saveDelays = []
    }

    func load() async throws -> SearchHistory {
        loadCount += 1
        try await Task.sleep(for: loadDelay)
        return try loadResult.get()
    }

    func save(_ history: SearchHistory) async throws {
        if !saveDelays.isEmpty {
            try await Task.sleep(for: saveDelays.removeFirst())
        }
        savedHistories.append(history)
    }
}
