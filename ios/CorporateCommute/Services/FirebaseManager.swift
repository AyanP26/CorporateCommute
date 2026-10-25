import Foundation
import Combine

#if canImport(FirebaseCore)
import FirebaseCore
#endif

final class FirebaseManager {
    static let shared = FirebaseManager()

    private(set) var isFirebaseConfigured: Bool = false

    lazy var authService: AuthServiceProtocol = {
        if isFirebaseConfigured {
            return FirebaseAuthService()
        }
        return MockAuthService()
    }()

    lazy var rideService: RideServiceProtocol = {
        if isFirebaseConfigured {
            return FirestoreRideService()
        }
        return MockRideService()
    }()

    private init() {
        configureIfPossible()
    }

    func configureIfPossible() {
        // Verify GoogleService-Info.plist exists in main bundle
        guard let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("[CorporateCommute] Notice: GoogleService-Info.plist not found in bundle. Using Mock backend.")
            isFirebaseConfigured = false
            return
        }

        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            if let options = FirebaseOptions(contentsOfFile: plistPath) {
                FirebaseApp.configure(options: options)
                isFirebaseConfigured = true
                print("[CorporateCommute] Firebase successfully initialized with \(plistPath)")
            } else {
                print("[CorporateCommute] Warning: Could not parse FirebaseOptions from \(plistPath). Falling back to Mock.")
                isFirebaseConfigured = false
            }
        } else {
            isFirebaseConfigured = true
        }
        #else
        print("[CorporateCommute] FirebaseCore not linked. Running in Mock backend mode.")
        isFirebaseConfigured = false
        #endif
    }
}
