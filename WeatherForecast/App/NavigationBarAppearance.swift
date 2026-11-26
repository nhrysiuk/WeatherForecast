import SwiftUI
import UIKit

enum NavigationBarAppearance {
    static let tint = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .white : .black
    }

    static func apply() {
        guard #unavailable(iOS 26) else { return }
        UIBarButtonItem.appearance().tintColor = tint
    }
}

extension View {
    @ViewBuilder
    func navigationBarItemTint() -> some View {
        if #available(iOS 26, *) {
            self
        } else {
            tint(Color(uiColor: NavigationBarAppearance.tint))
        }
    }
}
