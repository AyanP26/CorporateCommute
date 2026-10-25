import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .never

    @FocusState private var isFocused: Bool
    @State private var isPasswordRevealed: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Optional Leading Icon
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isFocused ? AppTheme.accentBlue : AppTheme.placeholderText)
                    .frame(width: 22)
            }

            // Input Field
            Group {
                if isSecure && !isPasswordRevealed {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.placeholderText))
                        .textContentType(textContentType)
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.placeholderText))
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(autocapitalization)
                        .disableAutocorrection(keyboardType == .emailAddress)
                }
            }
            .focused($isFocused)
            .tint(.white) // White vertical cursor
            .foregroundColor(AppTheme.textLight)
            .font(.system(size: 15, weight: .regular))

            // Trailing Actions (Password reveal / Clear text)
            if isSecure {
                Button(action: {
                    isPasswordRevealed.toggle()
                }) {
                    Image(systemName: isPasswordRevealed ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.placeholderText.opacity(0.8))
                        .padding(4)
                }
            } else if !text.isEmpty && isFocused {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.placeholderText.opacity(0.7))
                        .padding(4)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: AppTheme.buttonHeight)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                .fill(AppTheme.inputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                        .stroke(
                            isFocused ? AppTheme.accentBlue.opacity(0.75) : Color.white.opacity(0.1),
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
                .shadow(color: isFocused ? AppTheme.accentBlue.opacity(0.25) : Color.clear, radius: 8, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .animation(.easeInOut(duration: 0.18), value: isFocused)
    }
}

#Preview {
    VStack(spacing: 16) {
        CustomTextField(placeholder: "Email Address", text: .constant("user@corp.com"), icon: "envelope.fill")
        CustomTextField(placeholder: "Password", text: .constant("secret"), icon: "lock.fill", isSecure: true)
    }
    .padding()
    .background(Color.black)
}
