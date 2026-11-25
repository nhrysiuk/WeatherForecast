import SwiftUI

struct ErrorStateView: View {
    enum Reason: Sendable {
        case offline
        case unavailable
    }

    private let reason: Reason
    private let retry: () -> Void

    init(_ reason: Reason, retry: @escaping () -> Void) {
        self.reason = reason
        self.retry = retry
    }

    var body: some View {
        ContentUnavailableView {
            Label {
                title
            } icon: {
                Image(systemName: symbolName)
            }
        } description: {
            message
        } actions: {
            Button(.tryAgain, action: retry)
                .buttonStyle(.borderedProminent)
        }
    }

    private var symbolName: String {
        switch reason {
        case .offline:
            "wifi.slash"
        case .unavailable:
            "exclamationmark.icloud"
        }
    }

    private var title: Text {
        switch reason {
        case .offline:
            Text(.offlineTitle)
        case .unavailable:
            Text(.unavailableTitle)
        }
    }

    private var message: Text {
        switch reason {
        case .offline:
            Text(.offlineMessage)
        case .unavailable:
            Text(.unavailableMessage)
        }
    }
}
