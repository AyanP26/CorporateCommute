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
        .font(.system(size: 16, weight: .regular))
        .padding(.horizontal, 24)
        .frame(height: AppTheme.buttonHeight)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                .fill(AppTheme.inputBackground)
        )
    }
}

#Preview {
    CustomTextField(placeholder: "Name", text: .constant(""))
        .padding()
        .background(Color.black)
}
