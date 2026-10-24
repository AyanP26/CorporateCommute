import SwiftUI

enum AppTheme {
    // Brand Colors (matching Android app palette and screenshots)
    static let bgTop = Color(red: 0x06 / 255.0, green: 0x09 / 255.0, blue: 0x1A / 255.0)
    static let bgBottomLeft = Color(red: 0x54 / 255.0, green: 0x00 / 255.0, blue: 0x58 / 255.0)
    static let bgBottomRight = Color(red: 0x14 / 255.0, green: 0x00 / 255.0, blue: 0x96 / 255.0)
    static let buttonPurple = Color(red: 0x3E / 255.0, green: 0x00 / 255.0, blue: 0x3B / 255.0)
    static let buttonPressed = Color(red: 0x58 / 255.0, green: 0x00 / 255.0, blue: 0x54 / 255.0)
    static let inputBackground = Color(red: 0x3E / 255.0, green: 0x00 / 255.0, blue: 0x3B / 255.0)
    static let placeholderText = Color(red: 0xD1 / 255.0, green: 0xD1 / 255.0, blue: 0xD1 / 255.0)
    static let textLight = Color.white

    // Metrics (matching Android ConstraintLayout dp values)
    static let buttonHeight: CGFloat = 56
    static let pillCornerRadius: CGFloat = 28
    static let horizontalPadding: CGFloat = 32
}
