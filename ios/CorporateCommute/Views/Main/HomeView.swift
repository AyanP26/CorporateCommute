import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()

                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(AppTheme.textLight)

                    Text("Welcome, \(authViewModel.currentUser?.name ?? "Commuter")!")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(AppTheme.textLight)

                    Text(authViewModel.currentUser?.email ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.placeholderText)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Commute Dashboard")
                            .font(.headline)
                            .foregroundColor(AppTheme.textLight)

                        Text("You're all set up with Corporate Commute. Rideshare schedules, vehicle pooling, and company routes will appear here.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.placeholderText)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.inputBackground)
                    .cornerRadius(AppTheme.inputCornerRadius)

                    Spacer()

                    PrimaryButton(title: "Log Out") {
                        authViewModel.logout()
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
