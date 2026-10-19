import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BackgroundGradient()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 40)

                    Text("Welcome Back")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(AppTheme.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 36)

                    VStack(spacing: 20) {
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
                            textContentType: .password
                        )
                    }

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                    }

                    Spacer(minLength: 40)

                    PrimaryButton(
                        title: authViewModel.isSubmitting ? "Logging in..." : "Login",
                        isEnabled: !authViewModel.isSubmitting
                    ) {
                        authViewModel.login()
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
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
