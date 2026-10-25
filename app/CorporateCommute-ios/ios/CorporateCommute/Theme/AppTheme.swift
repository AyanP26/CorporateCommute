import SwiftUI

enum AppTheme {
    // Brand Colors (matching Android app palette)
    static let bgTop = Color(red: 0x06 / 255.0, green: 0x09 / 255.0, blue: 0x1A / 255.0)
    static let bgBottom = Color(red: 0x54 / 255.0, green: 0x00 / 255.0, blue: 0x58 / 255.0)
    static let buttonPurple = Color(red: 0x3E / 255.0, green: 0x00 / 255.0, blue: 0x3B / 255.0)
    static let buttonHighlight = Color(red: 0x62 / 255.0, green: 0x00 / 255.0, blue: 0xEE / 255.0)
    static let inputBackground = Color.white.opacity(0.12)
    static let inputBorder = Color.white.opacity(0.25)
    static let placeholderText = Color(white: 0.82)
    static let textLight = Color.white

    // Gradients
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [bgTop, bgBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // Metrics
    static let buttonHeight: CGFloat = 56
    static let buttonCornerRadius: CGFloat = 28
    static let inputCornerRadius: CGFloat = 16
    static let horizontalPadding: CGFloat = 32
}
