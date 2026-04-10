import SwiftUI

extension View {
    func appInputChrome(isFocused: Bool, cornerRadius: CGFloat = AppTheme.Radius.sm) -> some View {
        background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isFocused ? AppTheme.Colors.accentGreen : AppTheme.Colors.borderSubtle,
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
    }

    func appDisabledLook(_ disabled: Bool) -> some View {
        opacity(disabled ? 0.55 : 1.0)
    }
}
