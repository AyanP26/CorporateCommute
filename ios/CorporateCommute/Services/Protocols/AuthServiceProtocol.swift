import Foundation
import Combine

protocol AuthServiceProtocol: AnyObject {
    var currentUserPublisher: AnyPublisher<User?, Never> { get }
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }

    func register(name: String, email: String, password: String, phoneNumber: String) async throws -> User
    func login(email: String, password: String) async throws -> User
    func updateUserProfile(_ user: User) async throws
    func logout() throws
}
