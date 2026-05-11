import SwiftUI
import Observation

enum LoginMethod {
    case email, google, apple
}

@Observable
@MainActor
final class AppRouter {
    var path = NavigationPath()
    var rootRoute: AppRoute = .onboarding
    var shouldAutoShowLogin = false
    var shouldAutoShowPinSetup = false
    var onRoutingError: ((String) -> Void)?

    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        determineRoot()
    }

    func determineRoot() {
        if sessionManager.isAuthenticated {
            if let user = sessionManager.currentUser, !user.isGuest {
                let hasPhone = user.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false

                if !user.isVerified {
                    if hasPhone {
                        rootRoute = .otpVerification(phoneNumber: user.phoneNumber!, token: sessionManager.authToken)
                    } else {
                        rootRoute = .login
                    }
                } else if !user.hasPin {
                    shouldAutoShowPinSetup = true
                    rootRoute = .mainTab
                } else {
                    rootRoute = .mainTab
                }
            } else {
                rootRoute = .mainTab
            }
        } else {
            rootRoute = .onboarding
        }
        path = NavigationPath()
    }

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func replace(with route: AppRoute) {
        path = NavigationPath()
        rootRoute = route
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path = NavigationPath()
    }

    // MARK: - Post-Login Routing (matches Android QA-approved flow)
    //
    // !isVerified && phone != null  → OTP Verification
    // !isVerified && phone == null:
    //   email login   → Error toast
    //   google/apple  → Phone Input
    // !hasPin && phone != null      → PIN Setup
    // !hasPin && phone == null      → Home (complete profile popup)
    // hasPin && isVerified          → Home

    func handleLoginSuccess(user: User, token: String?, loginMethod: LoginMethod = .email) async {
        if let token {
            await sessionManager.saveSession(user: user, token: token)
        } else {
            sessionManager.updateUser(user)
        }

        let hasPhone = user.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false

        if !user.isVerified {
            if hasPhone {
                replace(with: .otpVerification(phoneNumber: user.phoneNumber!, token: token))
            } else {
                switch loginMethod {
                case .email:
                    onRoutingError?("Nomor telepon tidak ditemukan, silakan hubungi customer service")
                case .google, .apple:
                    replace(with: .phoneInput(userId: user.id))
                }
            }
        } else if !user.hasPin {
            shouldAutoShowPinSetup = true
            replace(with: .mainTab)
        } else {
            replace(with: .mainTab)
        }
    }

    func handleGuestLogin() {
        sessionManager.saveGuestSession()
        replace(with: .mainTab)
    }

    func handleLogout() async {
        await sessionManager.clearSession()
        replace(with: .onboarding)
    }
}
