# ION Toll

A modern iOS toll payment application built with SwiftUI, providing seamless electronic toll collection experience for users in Indonesia.

## Tech Stack

| Category | Technology |
|---|---|
| Platform | iOS 18.4+ |
| Language | Swift 6 |
| UI Framework | SwiftUI |
| Architecture | MVVM + Observation |
| Networking | URLSession (async/await) |
| Local Storage | UserDefaults + Keychain |
| Authentication | Email, Google Sign-In, Sign in with Apple |
| Security | Keychain (tokens), ATS (HTTPS only) |
| Concurrency | Structured Concurrency (async/await, Actor) |
| Debugging | Pulse (Network Logger) |
| IDE | Xcode 26.4 |

## Features

- Email, Google, and Apple authentication
- OTP verification
- PIN setup and management
- Profile management with photo upload
- Password management
- Electronic toll payment
- Transaction history

## Getting Started

1. Clone the repository
2. Open `ION Toll.xcodeproj` in Xcode
3. Build and run on simulator or device

## Requirements

- Xcode 26.4+
- iOS 18.4+ deployment target
- Apple Developer account (for device testing)
