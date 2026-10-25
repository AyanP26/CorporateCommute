import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var navigateToCreateAccount = false
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()

                VStack(spacing: 0) {
                    Spacer(minLength: 40)

                    // Car Illustration with subtle luminous glow
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.accentBlue.opacity(0.35),
                                        AppTheme.bgBottomLeft.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 140)
                            .blur(radius: 20)

                        Image("CarIllustration")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 190, height: 125)
                            .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
                    }

                    // Title
                    VStack(spacing: 8) {
                        Text("Corporate Commute")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textLight)
                            .multilineTextAlignment(.center)

                        Text("Smart, eco-friendly carpooling for teams")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.placeholderText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 28)

                    // Button actions with clear visual hierarchy
                    VStack(spacing: 14) {
                        PrimaryButton(title: "Log In", style: .accent) {
                            navigateToLogin = true
                        }

                        PrimaryButton(title: "Create an Account", style: .secondary) {
                            navigateToCreateAccount = true
                        }
                    }
                    .padding(.top, 48)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
            }
            .navigationDestination(isPresented: $navigateToCreateAccount) {
                CreateAccountView()
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
