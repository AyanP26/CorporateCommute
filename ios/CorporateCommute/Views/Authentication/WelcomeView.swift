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
                    Spacer()

                    // Car Illustration matching Android's ic_car_illustration
                    Image("CarIllustration")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 120)

                    // Title matching Android's welcome_title
                    Text("Welcome to Corporate\nCommute!")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.top, 32)

                    // Buttons matching Android's packed layout
                    VStack(spacing: 16) {
                        PrimaryButton(title: "Login") {
                            navigateToLogin = true
                        }

                        PrimaryButton(title: "Create an Account") {
                            navigateToCreateAccount = true
                        }
                    }
                    .padding(.top, 48)

                    Spacer()
                    Spacer()
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
