import Domain
import Observation

@Observable
final class AppRouter {
    var path: [Route] = []

    private let historyStore: HistoryStore

    init(historyStore: HistoryStore) {
        self.historyStore = historyStore
    }

    func open(_ city: City) {
        path.append(.forecast(city))
        historyStore.record(city)
    }
}
