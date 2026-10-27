import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

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
        .multilineTextAlignment(.center)
        .foregroundColor(AppTheme.textLight)
        .font(.system(size: 16))
        .padding(.horizontal, 20)
        .frame(height: AppTheme.buttonHeight)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.inputCornerRadius)
                .fill(AppTheme.inputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.inputCornerRadius)
                        .stroke(AppTheme.inputBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    CustomTextField(placeholder: "Name", text: .constant(""))
        .padding()
        .background(Color.black)
}
