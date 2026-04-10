import SwiftUI

struct AccentGradientBar: View {
    var width: CGFloat = 28
    var height: CGFloat = 2

    var body: some View {
        LinearGradient(
            colors: [
                AppTheme.Colors.accentGreenBright,
                AppTheme.Colors.accentOrange
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: width, height: height)
        .clipShape(Capsule())
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.appBackground
            .ignoresSafeArea()
        AccentGradientBar()
    }
}
