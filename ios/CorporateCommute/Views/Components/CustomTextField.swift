import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.placeholderText))
                    .textContentType(textContentType)
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.placeholderText))
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .disableAutocorrection(keyboardType == .emailAddress)
            }
        }
        .focused($isFocused)
        .tint(.white) // Bright white vertical typing cursor (caret)
        .multilineTextAlignment(.center)
        .foregroundColor(AppTheme.textLight)
        .font(.system(size: 16, weight: .regular))
        .padding(.horizontal, 24)
        .frame(height: AppTheme.buttonHeight)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                .fill(AppTheme.inputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                        .stroke(isFocused ? Color.white.opacity(0.4) : Color.white.opacity(0.08), lineWidth: isFocused ? 1.5 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

#Preview {
    CustomTextField(placeholder: "Name", text: .constant(""))
        .padding()
        .background(Color.black)
}
