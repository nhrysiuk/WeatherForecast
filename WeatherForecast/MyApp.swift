import Networking
import OpenMeteo
import Persistence
import SwiftUI

@main struct MyApp: App {
    @State private var homeViewModel: HomeViewModel = {
        let httpClient = URLSessionHTTPClient()
        return HomeViewModel(
            citySearch: OpenMeteoCitySearch(httpClient: httpClient, locale: .current),
            historyStore: FileSearchHistoryStore(),
            forecastProvider: OpenMeteoForecastProvider(httpClient: httpClient)
        )
    }()

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: homeViewModel)
        }
    }
}
