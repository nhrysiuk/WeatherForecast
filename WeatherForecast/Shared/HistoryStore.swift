import Domain
import Foundation
import Observation
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WeatherForecast", category: "History")

@Observable
final class HistoryStore {
    private(set) var history = SearchHistory()
    private(set) var isLoaded = false

    private let repository: any SearchHistoryRepository
    @ObservationIgnored private var loading: Task<Void, Never>?
    @ObservationIgnored private var recording: Task<Void, Never>?
    @ObservationIgnored private var saving: Task<Void, Never>?

    init(repository: any SearchHistoryRepository) {
        self.repository = repository
    }

    func load() async {
        if loading == nil {
            loading = Task { await read() }
        }
        await loading?.value
    }

    func record(_ city: City) {
        recording = Task { [previous = recording] in
            await previous?.value
            await load()
            update { $0.record(city) }
        }
    }

    func remove(atOffsets offsets: IndexSet) {
        guard isLoaded else { return }
        update { $0.remove(atOffsets: offsets) }
    }

    func waitForSaves() async {
        await recording?.value
        await saving?.value
    }

    private func read() async {
        do {
            history = try await repository.load()
        } catch {
            logger.error("Loading history failed, starting with an empty one: \(String(describing: error), privacy: .public)")
        }
        isLoaded = true
    }

    private func update(_ change: (inout SearchHistory) -> Void) {
        var updated = history
        change(&updated)
        guard updated != history else { return }
        history = updated
        saving = Task { [previous = saving, repository] in
            await previous?.value
            do {
                try await repository.save(updated)
            } catch {
                logger.error("Saving history failed: \(String(describing: error), privacy: .public)")
            }
        }
    }
}
