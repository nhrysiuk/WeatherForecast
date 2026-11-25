import HomeFeature
import Networking
import OpenMeteo
import Persistence
import SwiftUI

@main struct MyApp: App {
    @State private var homeModel = HomeModel(
        citySearch: OpenMeteoCitySearch(httpClient: URLSessionHTTPClient(), locale: .current),
        historyStore: FileSearchHistoryStore()
    )

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(model: homeModel)
            }
        }
    }
}
