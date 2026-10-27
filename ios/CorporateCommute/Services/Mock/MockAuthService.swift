import Foundation
import Combine

final class MockAuthService: AuthServiceProtocol {
    private let currentUserSubject = CurrentValueSubject<User?, Never>(nil)

    var currentUserPublisher: AnyPublisher<User?, Never> {
        currentUserSubject.eraseToAnyPublisher()
    }

    var currentUser: User? {
        currentUserSubject.value
    }

    var isAuthenticated: Bool {
        currentUserSubject.value != nil
    }

    func register(name: String, email: String, password: String, phoneNumber: String) async throws -> User {
        try await Task.sleep(nanoseconds: 600_000_000)
        let user = User(
            id: UUID().uuidString,
            name: name,
            email: email,
            phoneNumber: phoneNumber
        )
        currentUserSubject.send(user)
        return user
    }

    func login(email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 600_000_000)
        let user = User(
            id: "mock_user_1",
            name: "Alex Morgan",
            email: email,
            phoneNumber: "+1 (555) 345-6789",
            officeLocation: "Corporate HQ - Innovation Campus",
            role: "Senior Consultant",
            company: "Corporate Global",
            jobTitle: "Senior Consultant",
            workLocation: CommuteLocation.corporateHQ
        )
        currentUserSubject.send(user)
        return user
    }

    func updateUserProfile(_ user: User) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        currentUserSubject.send(user)
    }

    func logout() throws {
        currentUserSubject.send(nil)
    }
}
