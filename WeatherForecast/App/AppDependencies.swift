import Domain
import Foundation
import Networking
import OpenMeteo
import Persistence

struct AppDependencies {
    let citySearch: any CitySearching
    let forecastProvider: any ForecastProviding
    let historyStore: HistoryStore

    static func live() -> AppDependencies {
        let httpClient = URLSessionHTTPClient()
        return AppDependencies(
            citySearch: OpenMeteoCitySearch(httpClient: httpClient, locale: .current),
            forecastProvider: OpenMeteoForecastProvider(httpClient: httpClient),
            historyStore: HistoryStore(repository: FileSearchHistoryRepository())
        )
    }
}
