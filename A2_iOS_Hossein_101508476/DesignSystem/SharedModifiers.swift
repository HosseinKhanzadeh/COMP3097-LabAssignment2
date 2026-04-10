import SwiftUI

struct AppScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.appBackground.ignoresSafeArea())
    }
}

struct AppContentPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(.horizontal, AppTheme.Spacing.screenHorizontal)
    }
}

struct ElevatedCardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.Radius.lg

    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: AppTheme.Shadow.elevatedColor,
                radius: AppTheme.Shadow.elevatedRadius,
                x: 0,
                y: AppTheme.Shadow.elevatedYOffset
            )
    }
}

struct AppDividerLine: View {
    var verticalPadding: CGFloat = AppTheme.Spacing.sm

    var body: some View {
        Rectangle()
            .fill(AppTheme.Colors.divider)
            .frame(height: 1)
            .padding(.vertical, verticalPadding)
    }
}

struct AppSubtlePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.93 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SubtleBorderedSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.Radius.md

    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.Colors.borderSubtle, lineWidth: 1)
            )
    }
}

extension View {
    func appScreenBackground() -> some View {
        modifier(AppScreenBackgroundModifier())
    }

    func appContentPadding() -> some View {
        modifier(AppContentPaddingModifier())
    }

    func elevatedProductCard(cornerRadius: CGFloat = AppTheme.Radius.lg) -> some View {
        modifier(ElevatedCardModifier(cornerRadius: cornerRadius))
    }

    func subtleBorderedSurface(cornerRadius: CGFloat = AppTheme.Radius.md) -> some View {
        modifier(SubtleBorderedSurfaceModifier(cornerRadius: cornerRadius))
    }

    func appSubtlePressButtonStyle() -> some View {
        buttonStyle(AppSubtlePressButtonStyle())
    }
}
