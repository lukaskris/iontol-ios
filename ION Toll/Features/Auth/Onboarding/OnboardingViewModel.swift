import Foundation
import Observation

@Observable
@MainActor
final class OnboardingViewModel {
    var isGoogleLoading = false
    var isAppleLoading = false
    var onError: ((String) -> Void)?

    private let appleSignInService = AppleSignInService()
    private let googleSignInService = GoogleSignInService()
    private let authRepository: AuthRepositoryProtocol
    let sessionManager: SessionManager
    let router: AppRouter

    init(authRepository: AuthRepositoryProtocol, sessionManager: SessionManager, router: AppRouter) {
        self.authRepository = authRepository
        self.sessionManager = sessionManager
        self.router = router
    }

    func signInWithApple() async {
        isAppleLoading = true
        defer { isAppleLoading = false }

        do {
            let result = try await appleSignInService.signIn()
            // Login via API to get full user + token
            let apiService = AuthApiService()
            let response = try await apiService.loginApple(token: result.identityToken)

            guard let loginData = response.data else {
                onError?(response.message)
                return
            }

            let user = User(from: loginData)
            let token = loginData.token ?? ""

            await router.handleLoginSuccess(user: user, token: token, loginMethod: .apple)
        } catch is CancellationError {
            // User cancelled — ignore
        } catch {
            guard !error.isUserCancellation else { return }
            onError?(error.localizedDescription)
        }
    }

    func signInWithGoogle() async {
        isGoogleLoading = true
        defer { isGoogleLoading = false }

        do {
            let idToken = try await googleSignInService.signIn()
            let apiService = AuthApiService()
            let response = try await apiService.loginGoogle(token: idToken)

            guard let loginData = response.data else {
                onError?(response.message)
                return
            }

            let user = User(from: loginData)
            let token = loginData.token ?? ""

            await router.handleLoginSuccess(user: user, token: token, loginMethod: .google)
        } catch is CancellationError {
            // User cancelled — ignore
        } catch {
            guard !error.isUserCancellation else { return }
            onError?(error.localizedDescription)
        }
    }

    func loginAsGuest() {
        router.handleGuestLogin()
    }

    /// Call after setting onError to bridge routing errors through the same callback
    func setupRoutingErrorHandler() {
        router.onRoutingError = { [weak self] message in
            self?.onError?(message)
        }
    }
}
