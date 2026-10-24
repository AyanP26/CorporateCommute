import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BackgroundGradient()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 40)

                    Text("Welcome Back")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)
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
                            .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                    }

                    PrimaryButton(
                        title: authViewModel.isSubmitting ? "Logging in..." : "Login",
                        isEnabled: !authViewModel.isSubmitting
                    ) {
                        authViewModel.login()
                    }
                    .padding(.top, 36)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textLight)
                        .padding(8)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
