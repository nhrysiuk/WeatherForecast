import SwiftUI

struct EmptyView: View {
    
    var messageText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.warninglight.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            Text(messageText)
                .font(.headline)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .foregroundStyle(.gray)
    }
}
