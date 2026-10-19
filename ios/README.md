# Corporate Commute - iOS App

A native iOS application for **Corporate Commute** built with SwiftUI, following modern MVVM architecture and maintaining feature and design parity with the Android app.

---

## 📱 Features

- **Welcome & Onboarding**: Branded landing screen with car illustration, matching gradients (`#06091A` to `#540058`), and authentication entry points.
- **Account Creation**: Full registration flow with validated inputs for Name, Email, Password, and Phone Number.
- **Authentication**: Sign-in and session state management via `AuthViewModel`.
- **Commuter Dashboard**: Post-login view ready for rideshare schedules, vehicle pooling, and company routes.
- **Automated Tests**: Unit test suite (`CorporateCommuteTests`) and UI test suite (`CorporateCommuteUITests`) verifying flows end-to-end.

---

## 📂 Project Structure

```
ios/
├── CorporateCommute.xcodeproj/     # Xcode project file with shared scheme
├── CorporateCommute/               # Main application source
│   ├── App/
│   │   └── CorporateCommuteApp.swift  # App entry point (@main) & environment setup
│   ├── Models/
│   │   └── User.swift                 # User data model (Identifiable, Codable)
│   ├── ViewModels/
│   │   └── AuthViewModel.swift        # State management, input validation, auth flow
│   ├── Views/
│   │   ├── Authentication/
│   │   │   ├── WelcomeView.swift      # Welcome screen (matching Android MainActivity)
│   │   │   ├── CreateAccountView.swift# Registration screen (matching Android CreateAccountActivity)
│   │   │   └── LoginView.swift        # Sign-in screen
│   │   ├── Components/
│   │   │   ├── BackgroundGradient.swift # Reusable brand gradient background
│   │   │   ├── CustomTextField.swift   # Styled rounded text input field
│   │   │   └── PrimaryButton.swift     # Reusable rounded action button
│   │   └── Main/
│   │       └── HomeView.swift         # Authenticated commuter dashboard
│   ├── Theme/
│   │   └── AppTheme.swift             # Design tokens (colors, gradients, dimensions)
│   ├── Resources/
│   │   ├── Assets.xcassets/           # App icons, accent colors, and asset catalogs
│   │   └── Preview Content/           # SwiftUI canvas preview assets
│   └── Info.plist                     # Target configuration and capabilities
├── CorporateCommuteTests/             # Unit tests
│   └── CorporateCommuteTests.swift
├── CorporateCommuteUITests/           # UI automation tests
│   └── CorporateCommuteUITests.swift
├── .gitignore                         # Xcode & iOS specific ignore rules
└── README.md                          # Documentation
```

---

## 🛠️ Requirements & Setup

- **macOS**: Sonoma 14+ / Sequoia 15+
- **Xcode**: 15.0+ (iOS 17.0+ deployment target)
- **Swift**: 5.0+ / 6.0

### Opening in Xcode
Double-click `CorporateCommute.xcodeproj` located inside the `ios/` folder or open from terminal:
```bash
open ios/CorporateCommute.xcodeproj
```

Select an iOS Simulator (e.g., iPhone 15/16) and click **Run** (`⌘R`).

### Building from Command Line
```bash
xcodebuild -project ios/CorporateCommute.xcodeproj \
           -scheme CorporateCommute \
           -destination 'generic/platform=iOS Simulator' \
           build CODE_SIGNING_ALLOWED=NO
```

### Running Tests
```bash
xcodebuild -project ios/CorporateCommute.xcodeproj \
           -scheme CorporateCommute \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           test CODE_SIGNING_ALLOWED=NO
```

---

## 🎨 Design Alignment with Android

| Component | Android Spec | iOS SwiftUI Implementation |
|---|---|---|
| Background Gradient | `#06091A` to `#540058` | `AppTheme.backgroundGradient` |
| Primary Button Color | `#3E003B` | `AppTheme.buttonPurple` |
| Button Height & Radius | `56dp`, `28dp` corners | `PrimaryButton` (56pt, cornerRadius 28) |
| Input Fields | `bg_input_field` (white 12% fill) | `CustomTextField` (white 12% fill, 16pt corners) |
| App Identifier | `com.example.corporatecommute` | `com.example.corporatecommute` |
