import Foundation
import Combine

final class MockAuthService: AuthServiceProtocol {
    @Published private var _currentUser: User? = nil

    var currentUserPublisher: AnyPublisher<User?, Never> {
        $_currentUser.eraseToAnyPublisher()
    }

    var currentUser: User? {
        _currentUser
    }

    var isAuthenticated: Bool {
        _currentUser != nil
    }

    func register(name: String, email: String, password: String, phoneNumber: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        guard email.contains("@") else {
            throw NSError(domain: "AuthError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid email address."])
        }
        guard password.count >= 6 else {
            throw NSError(domain: "AuthError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Password must be at least 6 characters."])
        }

        let user = User(
            id: UUID().uuidString,
            name: name.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces).lowercased(),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces)
        )
        await MainActor.run {
            self._currentUser = user
        }
        return user
    }

    func login(email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)

        guard email.contains("@") && password.count >= 6 else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid email or password."])
        }

        let user = User(
            id: UUID().uuidString,
            name: "Commuter",
            email: email.lowercased(),
            phoneNumber: ""
        )
        await MainActor.run {
            self._currentUser = user
        }
        return user
    }

    func logout() throws {
        self._currentUser = nil
    }
}
