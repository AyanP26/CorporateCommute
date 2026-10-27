import Foundation
import Combine

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

final class FirebaseAuthService: AuthServiceProtocol {
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

    init() {
        #if canImport(FirebaseAuth)
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            if let fUser = firebaseUser {
                self.fetchUserProfile(uid: fUser.uid, fallbackEmail: fUser.email ?? "", fallbackName: fUser.displayName ?? "")
            } else {
                Task { @MainActor in
                    self._currentUser = nil
                }
            }
        }
        #endif
    }

    func register(name: String, email: String, password: String, phoneNumber: String) async throws -> User {
        #if canImport(FirebaseAuth)
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let firebaseUser = authResult.user

        // Update display name in Firebase Auth
        let changeRequest = firebaseUser.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()

        let user = User(
            id: firebaseUser.uid,
            name: name,
            email: email,
            phoneNumber: phoneNumber
        )

        // Save extended profile to Firestore
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        try await db.collection("users").document(firebaseUser.uid).setData(user.dictionaryRepresentation)
        #endif

        await MainActor.run {
            self._currentUser = user
        }
        return user
        #else
        throw NSError(
            domain: "FirebaseError",
            code: 501,
            userInfo: [NSLocalizedDescriptionKey: "FirebaseAuth SDK is not linked."]
        )
        #endif
    }

    func login(email: String, password: String) async throws -> User {
        #if canImport(FirebaseAuth)
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let firebaseUser = authResult.user

        let user = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? "Commuter",
            email: firebaseUser.email ?? email,
            phoneNumber: firebaseUser.phoneNumber ?? ""
        )

        await MainActor.run {
            self._currentUser = user
        }

        // Fetch full profile from Firestore in background
        fetchUserProfile(uid: firebaseUser.uid, fallbackEmail: user.email, fallbackName: user.name)

        return user
        #else
        throw NSError(
            domain: "FirebaseError",
            code: 501,
            userInfo: [NSLocalizedDescriptionKey: "FirebaseAuth SDK is not linked."]
        )
        #endif
    }

    func updateUserProfile(_ user: User) async throws {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        try await db.collection("users").document(user.id).setData(user.dictionaryRepresentation, merge: true)
        #endif

        #if canImport(FirebaseAuth)
        if let fUser = Auth.auth().currentUser, fUser.displayName != user.name {
            let changeRequest = fUser.createProfileChangeRequest()
            changeRequest.displayName = user.name
            try await changeRequest.commitChanges()
        }
        #endif

        await MainActor.run {
            self._currentUser = user
        }
    }

    func logout() throws {
        #if canImport(FirebaseAuth)
        try Auth.auth().signOut()
        #endif
        self._currentUser = nil
    }

    private func fetchUserProfile(uid: String, fallbackEmail: String, fallbackName: String) {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            guard let self = self else { return }
            if let data = snapshot?.data(), let user = User(dictionary: data) {
                Task { @MainActor in
                    self._currentUser = user
                }
            } else {
                Task { @MainActor in
                    self._currentUser = User(id: uid, name: fallbackName, email: fallbackEmail)
                }
            }
        }
        #else
        Task { @MainActor in
            self._currentUser = User(id: uid, name: fallbackName, email: fallbackEmail)
        }
        #endif
    }
}
