# TwoDo iOS App

Native iOS application for TwoDo - a couples-focused life management platform.

## 🏗️ Architecture

This app follows the **MVVM (Model-View-ViewModel)** architecture pattern with SwiftUI.

### Project Structure

```
TwoDo/
├── App/                          # App lifecycle and entry point
│   ├── TwoDoApp.swift           # Main app struct
│   └── ContentView.swift        # Root view with auth routing
├── Core/                         # Core utilities and services
│   ├── Network/                 # API client and networking
│   │   ├── APIClient.swift     # Base HTTP client
│   │   ├── APIConfig.swift     # API configuration
│   │   ├── APIEndpoint.swift   # Endpoint definitions
│   │   └── APIError.swift      # Error handling
│   ├── Storage/                 # Data persistence
│   │   └── KeychainManager.swift # Secure token storage
│   └── Extensions/              # Swift extensions (future)
├── Models/                       # Data models
│   └── User.swift              # User and auth models
├── ViewModels/                   # Business logic layer
│   └── AuthViewModel.swift     # Authentication logic
├── Views/                        # SwiftUI views
│   ├── Authentication/         # Auth screens
│   │   ├── LoginView.swift
│   │   ├── SignupView.swift
│   │   └── ForgotPasswordView.swift
│   ├── Dashboard/              # Main app screens
│   │   ├── DashboardView.swift
│   │   └── CoupleSetupView.swift
│   ├── Routines/               # Routine tracking (Sprint 3)
│   ├── Calendar/               # Events and calendar (Sprint 3)
│   ├── Settings/               # Settings screens (Sprint 4)
│   └── Components/             # Reusable UI components
│       ├── CustomTextField.swift
│       └── CustomButton.swift
└── Resources/                    # Assets and resources
    └── Assets.xcassets
```

## 📋 Requirements

- **Xcode**: 15.0 or later
- **iOS**: 16.0 or later
- **Swift**: 5.9 or later
- **Backend**: TwoDo API running (see `/apps/api`)

## 🚀 Getting Started

### 1. Prerequisites

Make sure you have:
- Xcode installed from the Mac App Store
- TwoDo backend API running (default: `http://localhost:3000`)

### 2. Open in Xcode

```bash
# From the repository root
cd apps/ios
open TwoDo.xcodeproj  # Create this if doesn't exist
```

Or manually create the Xcode project:
1. Open Xcode
2. File → New → Project
3. Choose "iOS" → "App"
4. Product Name: "TwoDo"
5. Organization Identifier: "com.twodo"
6. Interface: SwiftUI
7. Language: Swift
8. Storage: None (we'll use our own)
9. Save to: `/apps/ios/`

### 3. Add Source Files

Add all the Swift files from the directory structure above to your Xcode project:
- Drag the `App/`, `Core/`, `Models/`, `ViewModels/`, and `Views/` folders into your project
- Make sure "Copy items if needed" is checked
- Select "Create groups"

### 4. Configure API Endpoint

Edit `Core/Network/APIConfig.swift` and set the correct API URL:

```swift
static let baseURL = "http://localhost:3000" // Development
// Or for device testing:
// static let baseURL = "http://YOUR_COMPUTER_IP:3000"
```

### 5. Build and Run

1. Select a simulator (iPhone 15 Pro recommended)
2. Click the "Play" button or press `Cmd + R`
3. The app should launch with the login screen

## 🧪 Testing

### Run Tests
```bash
# In Xcode
Cmd + U
```

### Manual Testing
1. Create a test account via the signup flow
2. Check your console for the verification email link
3. Login with your credentials
4. Test couple creation/joining

## 🔧 Development

### Current Sprint: Sprint 1 - Foundation ✅

**Completed:**
- [x] Project setup and structure
- [x] API client with URLSession
- [x] Authentication models
- [x] Keychain token management
- [x] Authentication ViewModels
- [x] Login/Signup/Forgot Password views
- [x] Reusable components (CustomTextField, CustomButton)
- [x] Placeholder dashboard views

### Next Sprint: Sprint 2 - Tasks & Couples

**TODO:**
- [ ] Couple models and ViewModels
- [ ] Task models and ViewModels
- [ ] Local caching with SwiftData
- [ ] Task list UI
- [ ] Task detail UI
- [ ] Couple setup screens

## 📚 Key Features

### Authentication Flow
1. User opens app
2. `checkAuthStatus()` verifies token
3. If valid → Dashboard
4. If invalid → Login screen
5. After login → Save tokens to Keychain
6. Auto-refresh expired tokens

### API Integration
- Base URL: Configurable via `APIConfig`
- Auth: JWT Bearer tokens
- Token Storage: Keychain (secure)
- Auto-refresh: Handled by `APIClient`
- Error Handling: User-friendly messages

### Security
- Tokens stored in iOS Keychain
- Secure password fields
- HTTPS only in production
- No plaintext credentials in memory

## 🎨 Design System

### Colors
- Primary: Blue (`Color.blue`)
- Secondary: Pink (`Color.pink`)
- Success: Green (`Color.green`)
- Error: Red (`Color.red`)

### Typography
- Title: `.largeTitle` + `.bold`
- Headline: `.title` + `.semibold`
- Body: `.body`
- Caption: `.caption`

### Spacing
- Small: 8pt
- Medium: 16pt
- Large: 24pt
- XLarge: 32pt

## 🐛 Troubleshooting

### "Cannot connect to API"
- Ensure backend is running: `cd apps/api && pnpm dev`
- Check API URL in `APIConfig.swift`
- For device testing, use your computer's IP instead of `localhost`

### "Token expired"
- Logout and login again
- Check that token refresh is working in `APIClient.swift`

### "Keychain error"
- Reset the simulator: Device → Erase All Content and Settings
- Or manually delete keychain items

### Build Errors
- Clean build folder: `Cmd + Shift + K`
- Restart Xcode
- Check that all files are added to target

## 📖 API Documentation

All API endpoints are documented in `/IPHONE_APP_SPEC.md`.

Quick reference:
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login
- `POST /api/auth/refresh` - Refresh token
- `GET /api/auth/me` - Get current user
- See `Core/Network/APIEndpoint.swift` for full list

## 🚢 Deployment

### TestFlight (Beta)
1. Archive the app: Product → Archive
2. Upload to App Store Connect
3. Add testers in App Store Connect
4. Send invites

### App Store
1. Complete metadata in App Store Connect
2. Submit for review
3. Wait 1-3 days for approval
4. Release to users

## 📝 Next Steps

1. **Complete Sprint 2**: Tasks and Couples functionality
2. **Add Tests**: Unit tests for ViewModels
3. **UI Tests**: Critical user flows
4. **Polish**: Animations and transitions
5. **Performance**: Profile with Instruments

## 🤝 Contributing

See the main repository README for contribution guidelines.

## 📄 License

See LICENSE file in the repository root.

---

**Current Version**: 0.1.0 (Sprint 1 Complete)
**Last Updated**: 2025-11-21
**Status**: 🚧 In Development
