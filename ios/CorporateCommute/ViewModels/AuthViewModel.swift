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

    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol = FirebaseManager.shared.authService) {
        self.authService = authService

        // Subscribe to auth service user state
        authService.currentUserPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = (user != nil)
            }
            .store(in: &cancellables)
    }

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

        let regName = name.trimmingCharacters(in: .whitespaces)
        let regEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        let regPassword = password
        let regPhone = phoneNumber.trimmingCharacters(in: .whitespaces)

        Task { @MainActor in
            do {
                let user = try await authService.register(
                    name: regName,
                    email: regEmail,
                    password: regPassword,
                    phoneNumber: regPhone
                )
                self.isSubmitting = false
                self.password = "" // Purge password from memory
                self.currentUser = user
                self.isAuthenticated = true
            } catch {
                self.isSubmitting = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func login() {
        guard isLoginValid else {
            errorMessage = "Please enter a valid email and password."
            return
        }

        isSubmitting = true
        errorMessage = nil

        let loginEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        let loginPassword = password

        Task { @MainActor in
            do {
                let user = try await authService.login(
                    email: loginEmail,
                    password: loginPassword
                )
                self.isSubmitting = false
                self.password = "" // Purge password from memory
                self.currentUser = user
                self.isAuthenticated = true
            } catch {
                self.isSubmitting = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func logout() {
        do {
            try authService.logout()
        } catch {
            print("[AuthViewModel] Logout error: \(error.localizedDescription)")
        }
        currentUser = nil
        isAuthenticated = false
        name = ""
        email = ""
        password = ""
        phoneNumber = ""
        errorMessage = nil
    }
}
