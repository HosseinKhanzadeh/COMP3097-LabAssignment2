import SwiftUI

struct ValidationBanner: View {
    var title: String
    let message: String

    init(title: String = "Validation Error", message: String) {
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(AppTheme.Colors.errorText)
                    .font(.system(size: 16, weight: .semibold))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.fieldLabel)
                        .foregroundStyle(AppTheme.Colors.errorText)
                    Text(message)
                        .font(AppTheme.Typography.body15)
                        .foregroundStyle(AppTheme.Colors.errorText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.errorBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .stroke(AppTheme.Colors.errorBorder, lineWidth: 1)
        )
    }
}
