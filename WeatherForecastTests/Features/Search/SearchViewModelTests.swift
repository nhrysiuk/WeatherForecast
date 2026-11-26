import Domain
import Foundation
import Testing
@testable import WeatherForecast

struct SearchViewModelTests {
    private let gdansk = City.stub(id: 1, name: "Gdańsk")

    @Test(arguments: ["", " ", "a"])
    func waitsForAtLeastTwoLetters(query: String) async {
        let viewModel = makeModel(search: .unexpected)

        await viewModel.search(for: query)

        #expect(viewModel.state == .idle)
    }

    @Test func rejectsInvalidNameWithoutSearching() async {
        let viewModel = makeModel(search: .unexpected)

        await viewModel.search(for: "Gdańsk 2")

        #expect(viewModel.state == .invalid(.containsDigits))
    }

    @Test func searchesForNormalizedName() async {
        let viewModel = makeModel(search: StubCitySearch { name in
            name == "Gdańsk" ? [City.stub(id: 1, name: "Gdańsk")] : []
        })

        await viewModel.search(for: "  Gdańsk ")

        #expect(viewModel.state == .results([gdansk]))
    }

    @Test(arguments: [WeatherError.offline, .server])
    func showsSearchFailure(error: WeatherError) async {
        let viewModel = makeModel(search: StubCitySearch { _ in throw error })

        await viewModel.search(for: "Gdańsk")

        #expect(viewModel.state == .failed(error))
    }

    @Test func ignoresResultsOfCancelledSearch() async {
        let (started, startedContinuation) = AsyncStream<Void>.makeStream()
        let (release, releaseContinuation) = AsyncStream<Void>.makeStream()
        let viewModel = makeModel(search: StubCitySearch { _ in
            startedContinuation.yield()
            for await _ in release {}
            return [City.stub(id: 1, name: "Gdańsk")]
        })
        let search = Task { await viewModel.search(for: "Gdańsk") }
        var startedIterator = started.makeAsyncIterator()
        await startedIterator.next()

        search.cancel()
        await search.value
        releaseContinuation.finish()

        #expect(viewModel.state == .loading)
    }

    @Test func ignoresFailureOfCancelledSearch() async {
        let (started, startedContinuation) = AsyncStream<Void>.makeStream()
        let (release, releaseContinuation) = AsyncStream<Void>.makeStream()
        let viewModel = makeModel(search: StubCitySearch { _ in
            startedContinuation.yield()
            for await _ in release {}
            throw WeatherError.server
        })
        let search = Task { await viewModel.search(for: "Gdańsk") }
        var startedIterator = started.makeAsyncIterator()
        await startedIterator.next()

        search.cancel()
        await search.value
        releaseContinuation.finish()

        #expect(viewModel.state == .loading)
    }

    private func makeModel(search: StubCitySearch) -> SearchViewModel {
        SearchViewModel(citySearch: search, debounce: .zero)
    }
}
