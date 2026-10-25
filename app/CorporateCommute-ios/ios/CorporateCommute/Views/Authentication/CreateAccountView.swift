import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BackgroundGradient()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 24)

                    Text("Create an Account")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(AppTheme.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 36)

                    VStack(spacing: 20) {
                        CustomTextField(
                            placeholder: "Name",
                            text: $authViewModel.name,
                            textContentType: .name
                        )

                        CustomTextField(
                            placeholder: "Email",
                            text: $authViewModel.email,
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress
                        )

                        CustomTextField(
                            placeholder: "Password",
                            text: $authViewModel.password,
                            isSecure: true,
                            textContentType: .newPassword
                        )

                        CustomTextField(
                            placeholder: "Phone Number",
                            text: $authViewModel.phoneNumber,
                            keyboardType: .phonePad,
                            textContentType: .telephoneNumber
                        )
                    }

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                    }

                    Spacer(minLength: 36)

                    PrimaryButton(
                        title: authViewModel.isSubmitting ? "Submitting..." : "Submit",
                        isEnabled: !authViewModel.isSubmitting
                    ) {
                        authViewModel.register()
                    }
                    .padding(.top, 36)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
            }
        }
        .navigationBarBackButtonHidden(false)
        .tint(AppTheme.textLight)
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
            .environmentObject(AuthViewModel())
    }
}
