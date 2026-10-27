# Corporate Commute - iOS App

A native iOS application for **Corporate Commute** built with SwiftUI, following clean MVVM architecture, design parity with the Android app, and fully configured for a Firebase backend implementation.

---

## 📱 Features

- **Welcome & Onboarding**: Branded landing screen with vector car illustration, matching dark navy & magenta/indigo gradients, and navigation.
- **Account Creation & Login**: Registration and sign-in flow with validated inputs for Name, Email, Password, and Phone Number.
- **Commuter Dashboard**: Real-time carpooling dashboard with today's scheduled ride hero card, colleague carpool finder, and eco sustainability metrics.
- **Firebase Ready Architecture**: Protocol-based service layer (`AuthServiceProtocol`, `RideServiceProtocol`) with `FirebaseManager` handling automatic switching between live Firebase (when `GoogleService-Info.plist` is provided) and local mock mode.

---

## 📂 Project Structure

```
ios/
├── CorporateCommute.xcodeproj/     # Xcode project file with shared scheme
├── CorporateCommute/               # Main application source
│   ├── App/
│   │   └── CorporateCommuteApp.swift  # App entry point & Firebase configuration
│   ├── Models/
│   │   ├── User.swift                 # User model (Firestore compatible)
│   │   └── CommuteRide.swift          # Carpool ride model (Firestore compatible)
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift        # Authentication state & validation
│   │   └── CommuteDashboardViewModel.swift # Dashboard state, carpools, & eco stats
│   ├── Services/                      # Backend Service Layer
│   │   ├── FirebaseManager.swift      # Firebase initialization & dependency injection
│   │   ├── Protocols/
│   │   │   ├── AuthServiceProtocol.swift # Auth contract
│   │   │   └── RideServiceProtocol.swift # Carpool/ride contract
│   │   ├── Mock/                      # Offline / preview services
│   │   │   ├── MockAuthService.swift
│   │   │   └── MockRideService.swift
│   │   └── Firebase/                  # Live Firebase services
│   │       ├── FirebaseAuthService.swift # Firebase Auth & Firestore user sync
│   │       └── FirestoreRideService.swift# Real-time Cloud Firestore rides
│   ├── Views/
│   │   ├── Authentication/
│   │   │   ├── WelcomeView.swift      # Welcome screen (matching Android MainActivity)
│   │   │   ├── CreateAccountView.swift# Registration screen
│   │   │   └── LoginView.swift        # Sign-in screen
│   │   ├── Components/
│   │   │   ├── BackgroundGradient.swift # Navy, magenta, and indigo background
│   │   │   ├── CustomTextField.swift   # 28pt pill-shaped plum input field
│   │   │   ├── PrimaryButton.swift     # 28pt pill-shaped plum action button
│   │   │   └── RideCardView.swift      # Colleague carpool card
│   │   └── Main/
│   │       └── HomeView.swift         # Commuter dashboard
│   ├── Theme/
│   │   └── AppTheme.swift             # Brand color tokens & metrics
│   ├── Resources/
│   │   ├── Assets.xcassets/           # Icons, colors, and CarIllustration vector
│   │   ├── GoogleService-Info.plist.example # Sample Firebase config
│   │   └── Preview Content/           # SwiftUI preview assets
│   └── Info.plist                     # Target configuration
├── .gitignore
└── README.md
```

---

## 🔥 Connecting Live Firebase Backend

The code is pre-architected to seamlessly connect to Firebase:

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/) and create a project for **Corporate Commute**.
   - Under **Authentication**, enable the **Email/Password** sign-in method.
   - Under **Cloud Firestore**, create a database in production or test mode.

2. **Add iOS App to Firebase**:
   - Register an iOS app with Bundle ID: `com.ikshaankaul.corporatecommute`.
   - Download `GoogleService-Info.plist`.

3. **Add to Project**:
   - Move `GoogleService-Info.plist` into `ios/CorporateCommute/Resources/` in Xcode (ensure *"Copy items if needed"* and target *"CorporateCommute"* are checked).

4. **Add Firebase SDK in Xcode**:
   - In Xcode: **File** > **Add Package Dependencies...**
   - Enter repository URL: `https://github.com/firebase/firebase-ios-sdk`
   - Select packages:
     - `FirebaseAuth`
     - `FirebaseFirestore`
   - Click **Add Package**.

Once `GoogleService-Info.plist` is in the bundle, `FirebaseManager.shared` will automatically detect it and switch from mock mode to live Firebase Auth & Firestore!

---

## 🛠️ Building & Running

### Opening in Xcode
```bash
open ios/CorporateCommute.xcodeproj
```

### Building via CLI
```bash
xcodebuild -project ios/CorporateCommute.xcodeproj \
           -scheme CorporateCommute \
           -destination 'generic/platform=iOS Simulator' \
           build CODE_SIGNING_ALLOWED=NO
```
