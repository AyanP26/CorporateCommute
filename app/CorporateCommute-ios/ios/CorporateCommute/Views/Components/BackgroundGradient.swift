import SwiftUI

struct BackgroundGradient: View {
    var body: some View {
        AppTheme.backgroundGradient
            .ignoresSafeArea()
    }
}

#Preview {
    BackgroundGradient()
}
