import SwiftUI

enum AppTheme {
    // Brand Colors (matching Android app palette and screenshots)
    static let bgTop = Color(red: 0x06 / 255.0, green: 0x09 / 255.0, blue: 0x1A / 255.0)
    static let bgBottomLeft = Color(red: 0x54 / 255.0, green: 0x00 / 255.0, blue: 0x58 / 255.0)
    static let bgBottomRight = Color(red: 0x14 / 255.0, green: 0x00 / 255.0, blue: 0x96 / 255.0)
    static let buttonPurple = Color(red: 0x3E / 255.0, green: 0x00 / 255.0, blue: 0x3B / 255.0)
    static let buttonPressed = Color(red: 0x58 / 255.0, green: 0x00 / 255.0, blue: 0x54 / 255.0)
    static let inputBackground = Color(red: 0x3E / 255.0, green: 0x00 / 255.0, blue: 0x3B / 255.0)
    static let cardBackground = Color(red: 0x2D / 255.0, green: 0x07 / 255.0, blue: 0x30 / 255.0).opacity(0.85)
    static let cardBorder = Color.white.opacity(0.12)
    static let placeholderText = Color(red: 0xD1 / 255.0, green: 0xD1 / 255.0, blue: 0xD1 / 255.0)
    static let textLight = Color.white

    // Accent Highlights
    static let accentBlue = Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0)
    static let accentBlueSoft = Color(red: 0x15 / 255.0, green: 0x72 / 255.0, blue: 0xE8 / 255.0).opacity(0.2)
    static let accentPurple = Color(red: 0x9B / 255.0, green: 0x51 / 255.0, blue: 0xE0 / 255.0)
    static let ecoGreen = Color(red: 0x4E / 255.0, green: 0xD8 / 255.0, blue: 0x91 / 255.0)
    static let ecoGreenSoft = Color(red: 0x4E / 255.0, green: 0xD8 / 255.0, blue: 0x91 / 255.0).opacity(0.18)
    static let errorRed = Color(red: 1.0, green: 0.38, blue: 0.38)
    static let subtleOverlay = Color.black.opacity(0.3)

    // Metrics (matching Android ConstraintLayout dp values)
    static let buttonHeight: CGFloat = 56
    static let pillCornerRadius: CGFloat = 28
    static let cardCornerRadius: CGFloat = 22
    static let horizontalPadding: CGFloat = 32
}
