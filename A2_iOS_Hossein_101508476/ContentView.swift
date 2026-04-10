import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Product App")
                .font(.title)
            Text("Initializing...")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
