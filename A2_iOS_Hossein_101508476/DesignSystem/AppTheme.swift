import SwiftUI

enum AppTheme {
    enum Colors {
        static let appBackground = Color(hex: "0A0A0A")
        static let surface = Color(hex: "1C1C1E")
        static let primaryText = Color(hex: "FFFFFF")
        static let secondaryText = Color(hex: "9CA3AF")
        static let bodyMuted = Color(hex: "DDE1E7")
        static let tertiaryText = Color(hex: "6B7280")
        static let accentGreen = Color(hex: "16A34A")
        static let accentGreenBright = Color(hex: "22C55E")
        static let accentOrange = Color(hex: "F97316")
        static let borderSubtle = Color.white.opacity(0.05)
        static let divider = Color.white.opacity(0.10)
        static let scrim = Color.black.opacity(0.60)
        static let errorBackground = Color.red.opacity(0.10)
        static let errorBorder = Color.red.opacity(0.30)
        static let errorText = Color(hex: "EF4444")
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let screenHorizontal: CGFloat = 20
    }

    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let homeProductCard: CGFloat = 26
    }

    enum Typography {
        static let screenTitle = Font.system(size: 34, weight: .semibold)
        static let cardTitle = Font.system(size: 22, weight: .semibold)
        static let rowTitle = Font.system(size: 17, weight: .semibold)
        static let rowPrice = Font.system(size: 17, weight: .semibold)
        static let body15 = Font.system(size: 15, weight: .regular)
        static let button15 = Font.system(size: 15, weight: .medium)
        static let fieldLabel = Font.system(size: 14, weight: .medium)
        static let emptyTitle = Font.system(size: 20, weight: .semibold)
        static let metadataCaption = Font.system(size: 12, weight: .regular)
        static let iconInline = Font.system(size: 18, weight: .medium)
        static let iconChevron = Font.system(size: 18, weight: .semibold)
    }

    enum Shadow {
        static let elevatedColor = Color.black.opacity(0.36)
        static let elevatedRadius: CGFloat = 18
        static let elevatedYOffset: CGFloat = 6
    }
}
