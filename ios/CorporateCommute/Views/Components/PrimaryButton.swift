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
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
        }
        .buttonStyle(PrimaryButtonStyle(backgroundColor: backgroundColor, isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                    .fill(configuration.isPressed ? AppTheme.buttonPressed : backgroundColor.opacity(isEnabled ? 1.0 : 0.5))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    PrimaryButton(title: "Create an Account") {}
        .padding()
        .background(Color.black)
}
