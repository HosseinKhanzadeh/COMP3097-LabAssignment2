import SwiftUI

enum EmptyStateCardStyle {
    case elevated
    case flat
}

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let message: String
    var style: EmptyStateCardStyle
    var verticalPadding: CGFloat
    var primaryActionTitle: String?
    var primaryAction: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        style: EmptyStateCardStyle = .flat,
        verticalPadding: CGFloat = AppTheme.Spacing.xl,
        primaryActionTitle: String? = nil,
        primaryAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.style = style
        self.verticalPadding = verticalPadding
        self.primaryActionTitle = primaryActionTitle
        self.primaryAction = primaryAction
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            }

            Text(title)
                .font(AppTheme.Typography.emptyTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .multilineTextAlignment(.center)

            Text(message)
                .font(AppTheme.Typography.body15)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)

            if let primaryActionTitle, let primaryAction {
                Button(action: primaryAction) {
                    Text(primaryActionTitle)
                        .font(AppTheme.Typography.button15)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.accentGreen)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .padding(verticalPadding)
        .frame(maxWidth: .infinity)
        .modifier(EmptyStateCardContainerModifier(style: style))
    }
}

private struct EmptyStateCardContainerModifier: ViewModifier {
    let style: EmptyStateCardStyle

    func body(content: Content) -> some View {
        switch style {
        case .elevated:
            content
                .elevatedProductCard()
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                        .stroke(AppTheme.Colors.borderSubtle, lineWidth: 1)
                )
        case .flat:
            content
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                        .stroke(AppTheme.Colors.borderSubtle, lineWidth: 1)
                )
        }
    }
}
