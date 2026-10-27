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

                    // Car Illustration matching Android's ivCar
                    Image(systemName: "car.side.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(AppTheme.textLight)
                        .frame(width: 140, height: 90)
                        .padding(.bottom, 24)

                    // Title matching Android's welcome_title
                    Text("Welcome to Corporate\nCommute!")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(AppTheme.textLight)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Spacer(minLength: 40)

                    // Buttons
                    VStack(spacing: 16) {
                        PrimaryButton(title: "Login") {
                            navigateToLogin = true
                        }

                        PrimaryButton(title: "Create an Account") {
                            navigateToCreateAccount = true
                        }
                    }
                    .padding(.bottom, 48)
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
