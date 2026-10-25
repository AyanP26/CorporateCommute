import SwiftUI

enum PrimaryButtonStyleVariant {
    case primary
    case accent
    case secondary
}

struct PrimaryButton: View {
    let title: String
    var style: PrimaryButtonStyleVariant = .primary
    var backgroundColor: Color? = nil
    var foregroundColor: Color = AppTheme.textLight
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    private var resolvedBackground: Color {
        if let bg = backgroundColor { return bg }
        switch style {
        case .primary:
            return AppTheme.buttonPurple
        case .accent:
            return AppTheme.accentBlue
        case .secondary:
            return Color.white.opacity(0.08)
        }
    }

    private var resolvedBorder: Color {
        switch style {
        case .secondary:
            return Color.white.opacity(0.3)
        default:
            return Color.white.opacity(0.12)
        }
    }

    var body: some View {
        Button(action: {
            guard isEnabled && !isLoading else { return }
            action()
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.buttonHeight)
        }
        .buttonStyle(CustomButtonStyle(
            backgroundColor: resolvedBackground,
            borderColor: resolvedBorder,
            isEnabled: isEnabled && !isLoading
        ))
        .disabled(!isEnabled || isLoading)
    }
}

private struct CustomButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let borderColor: Color
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                    .fill(configuration.isPressed ? AppTheme.buttonPressed : backgroundColor.opacity(isEnabled ? 1.0 : 0.45))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Primary Button") {}
        PrimaryButton(title: "Accent Button", style: .accent) {}
        PrimaryButton(title: "Secondary Button", style: .secondary) {}
        PrimaryButton(title: "Loading...", isLoading: true) {}
    }
    .padding()
    .background(Color.black)
}
