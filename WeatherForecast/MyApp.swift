import Networking
import OpenMeteo
import Persistence
import SwiftUI

@main struct MyApp: App {
    @State private var homeModel: HomeModel = {
        let httpClient = URLSessionHTTPClient()
        return HomeModel(
            citySearch: OpenMeteoCitySearch(httpClient: httpClient, locale: .current),
            historyStore: FileSearchHistoryStore(),
            forecastProvider: OpenMeteoForecastProvider(httpClient: httpClient)
        )
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(model: homeModel)
            }
        }
    }
}
