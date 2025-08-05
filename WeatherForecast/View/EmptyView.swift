import SwiftUI

struct EmptyView: View {
    
    var message: (String, String)
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: message.1)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            Text(message.0)
                .font(.headline)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .foregroundStyle(.gray)
    }
}
