import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var phoneNumber: String = ""

    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var errorMessage: String? = nil
    @Published var isSubmitting: Bool = false

    var isRegistrationValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isLoginValid: Bool {
        email.contains("@") && password.count >= 6
    }

    func register() {
        guard isRegistrationValid else {
            errorMessage = "Please fill in all fields with valid information (password min 6 characters)."
            return
        }

        isSubmitting = true
        errorMessage = nil

        // In-memory UI simulation only. No accounts or passwords are saved to disk/device.
        // Backend API will handle user registration and persistence in the future.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.isSubmitting = false
            let newUser = User(
                name: self.name.trimmingCharacters(in: .whitespaces),
                email: self.email.trimmingCharacters(in: .whitespaces).lowercased(),
                phoneNumber: self.phoneNumber.trimmingCharacters(in: .whitespaces)
            )
            self.password = "" // Do not retain password in memory
            self.currentUser = newUser
            self.isAuthenticated = true
        }
    }

    func login() {
        guard isLoginValid else {
            errorMessage = "Please enter a valid email and password."
            return
        }

        isSubmitting = true
        errorMessage = nil

        // In-memory UI simulation only. Backend API will handle authentication.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.isSubmitting = false
            self.password = "" // Do not retain password in memory
            self.currentUser = User(
                name: "Commuter",
                email: self.email.lowercased(),
                phoneNumber: ""
            )
            self.isAuthenticated = true
        }
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
        name = ""
        email = ""
        password = ""
        phoneNumber = ""
        errorMessage = nil
    }
}
