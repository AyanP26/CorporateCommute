import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BackgroundGradient()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 32)

                    // Header
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                            .multilineTextAlignment(.center)

                        Text("Sign in to connect with your corporate carpools")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.placeholderText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 36)

                    // Form Fields
                    VStack(spacing: 16) {
                        CustomTextField(
                            placeholder: "Email Address",
                            text: $authViewModel.email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress,
                            autocapitalization: .never
                        )

                        CustomTextField(
                            placeholder: "Password",
                            text: $authViewModel.password,
                            icon: "lock.fill",
                            isSecure: true,
                            textContentType: .password
                        )
                    }

                    // Error Banner
                    if let errorMessage = authViewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(AppTheme.errorRed)
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.errorRed)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppTheme.errorRed.opacity(0.12))
                                .overlay(Capsule().stroke(AppTheme.errorRed.opacity(0.3), lineWidth: 1))
                        )
                        .padding(.top, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Login CTA
                    PrimaryButton(
                        title: authViewModel.isSubmitting ? "Logging in..." : "Log In",
                        style: .accent,
                        isEnabled: !authViewModel.isSubmitting,
                        isLoading: authViewModel.isSubmitting
                    ) {
                        authViewModel.login()
                    }
                    .padding(.top, 28)

                    // Switch to Sign Up
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundColor(AppTheme.placeholderText)
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.accentBlue)
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.top, 28)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textLight)
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
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
