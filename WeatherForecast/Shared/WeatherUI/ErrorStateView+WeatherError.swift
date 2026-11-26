import Domain

extension ErrorStateView.Reason {
    init(_ error: WeatherError) {
        switch error {
        case .offline:
            self = .offline
        case .server:
            self = .unavailable
        }
    }
}
