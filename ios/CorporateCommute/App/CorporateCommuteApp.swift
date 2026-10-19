import SwiftUI

@main
struct CorporateCommuteApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    HomeView()
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(authViewModel)
            .preferredColorScheme(.dark)
        }
    }
}
