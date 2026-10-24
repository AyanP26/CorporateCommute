import SwiftUI

struct BackgroundGradient: View {
    var body: some View {
        ZStack {
            // Base dark navy background
            AppTheme.bgTop

            // Vertical transition from dark navy into deep purple
            LinearGradient(
                colors: [
                    AppTheme.bgTop,
                    AppTheme.bgTop.opacity(0.85),
                    Color(red: 0x30 / 255.0, green: 0x00 / 255.0, blue: 0x44 / 255.0)
                ],
                startPoint: .top,
                endPoint: .center
            )

            // Bottom-left vibrant magenta-purple glow matching Android
            RadialGradient(
                colors: [
                    AppTheme.bgBottomLeft,
                    AppTheme.bgBottomLeft.opacity(0.65),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 40,
                endRadius: 550
            )

            // Bottom-right royal indigo-blue glow matching Android
            RadialGradient(
                colors: [
                    AppTheme.bgBottomRight,
                    AppTheme.bgBottomRight.opacity(0.75),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 40,
                endRadius: 550
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundGradient()
}
