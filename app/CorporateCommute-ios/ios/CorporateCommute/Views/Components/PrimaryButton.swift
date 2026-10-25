import SwiftUI

struct PrimaryButton: View {
    let title: String
    var backgroundColor: Color = AppTheme.buttonPurple
    var foregroundColor: Color = AppTheme.textLight
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
                .background(backgroundColor.opacity(isEnabled ? 1.0 : 0.5))
                .cornerRadius(AppTheme.buttonCornerRadius)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    PrimaryButton(title: "Create an Account") {}
        .padding()
        .background(Color.black)
}
