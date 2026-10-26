import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BackgroundGradient()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 28)

                    // Header
                    VStack(spacing: 8) {
                        Text("Create an Account")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                            .multilineTextAlignment(.center)

                        Text("Join your coworkers in greener, easier commutes")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.placeholderText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)

                    // Form Fields
                    VStack(spacing: 16) {
                        CustomTextField(
                            placeholder: "Full Name",
                            text: $authViewModel.name,
                            icon: "person.fill",
                            textContentType: .name,
                            autocapitalization: .words
                        )

                        CustomTextField(
                            placeholder: "Work Email Address",
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
                            textContentType: .newPassword
                        )

                        CustomTextField(
                            placeholder: "Phone Number",
                            text: $authViewModel.phoneNumber,
                            icon: "phone.fill",
                            keyboardType: .phonePad,
                            textContentType: .telephoneNumber
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

                    // Submit CTA
                    PrimaryButton(
                        title: authViewModel.isSubmitting ? "Creating Account..." : "Create Account",
                        style: .accent,
                        isEnabled: !authViewModel.isSubmitting,
                        isLoading: authViewModel.isSubmitting
                    ) {
                        authViewModel.register()
                    }
                    .padding(.top, 28)

                    // Switch to Log In
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundColor(AppTheme.placeholderText)
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Log In")
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.accentBlue)
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.top, 24)
                    .padding(.bottom, 36)
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
        CreateAccountView()
            .environmentObject(AuthViewModel())
    }
}
