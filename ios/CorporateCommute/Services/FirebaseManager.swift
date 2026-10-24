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
            print("""
            [CorporateCommute] Notice: 'GoogleService-Info.plist' not found in App Bundle.
            Running in Local Mock Backend mode.
            To connect to your live Firebase backend:
            1. Download GoogleService-Info.plist from your Firebase Console.
            2. Add it to ios/CorporateCommute/Resources/ in Xcode.
            3. Add the Firebase iOS SDK package in Xcode: https://github.com/firebase/firebase-ios-sdk
            """)
            isFirebaseConfigured = false
            return
        }

        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            isFirebaseConfigured = true
            print("[CorporateCommute] Firebase successfully initialized with \(plistPath)")
        }
        #else
        print("[CorporateCommute] GoogleService-Info.plist is present, but Firebase SDK is not yet linked via Swift Package Manager.")
        isFirebaseConfigured = false
        #endif
    }
}
