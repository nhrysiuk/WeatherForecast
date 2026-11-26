import SwiftUI

@main struct MyApp: App {
    private let dependencies: AppDependencies
    @State private var router: AppRouter

    init() {
        let dependencies = AppDependencies.live()
        self.dependencies = dependencies
        _router = State(initialValue: AppRouter(historyStore: dependencies.historyStore))
    }

    var body: some Scene {
        WindowGroup {
            HomeView(dependencies: dependencies, router: router)
        }
    }
}
