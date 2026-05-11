import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    var isLoading = false
    var errorMessage: String?

    let sessionManager: SessionManager
    let router: AppRouter

    init(sessionManager: SessionManager, router: AppRouter) {
        self.sessionManager = sessionManager
        self.router = router
    }

    var currentUser: User? {
        sessionManager.currentUser
    }

    func logout() async {
        await router.handleLogout()
    }
}
