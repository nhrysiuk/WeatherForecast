import SwiftUI

extension View {
    @ViewBuilder
    func cardBackground(cornerRadius: CGFloat = 22) -> some View {
        if #available(iOS 26, *) {
            glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            background(.thinMaterial, in: .rect(cornerRadius: cornerRadius))
        }
    }
}
