import Foundation
import Observation

@Observable
@MainActor
final class SessionManager {
    var currentUser: User?
    var authToken: String?
    var isAuthenticated: Bool { currentUser != nil }
    var isGuest: Bool { currentUser?.isGuest == true }

    private let keychain = KeychainService()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let token = "auth_token"
        static let userData = "user_data"
        static let isGuest = "is_guest_mode"
    }

    init() {
        loadSession()
    }

    // MARK: - Save Session

    func saveSession(user: User, token: String) async {
        currentUser = user
        authToken = token

        do {
            try await keychain.saveString(key: Keys.token, value: token)
            saveUserToDefaults(user)
        } catch {
            print("Failed to save session: \(error)")
        }
    }

    func saveGuestSession() {
        let guest = User.guest
        currentUser = guest
        authToken = nil
        defaults.set(true, forKey: Keys.isGuest)
        saveUserToDefaults(guest)

        Task {
            try? await keychain.delete(key: Keys.token)
        }
    }

    func updateUser(_ user: User) {
        currentUser = user
        saveUserToDefaults(user)
    }

    // MARK: - Clear Session

    func clearSession() async {
        currentUser = nil
        authToken = nil
        defaults.removeObject(forKey: Keys.userData)
        defaults.removeObject(forKey: Keys.isGuest)
        try? await keychain.deleteAll()
    }

    // MARK: - Private

    private func loadSession() {
        // Check guest mode
        if defaults.bool(forKey: Keys.isGuest) {
            let guest = User.guest
            currentUser = guest
            return
        }

        // Load user from UserDefaults
        if let userData = defaults.data(forKey: Keys.userData),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }

        // Load token from Keychain (async, fire and forget - will update authToken)
        Task {
            if let token = try? await keychain.loadString(key: Keys.token) {
                self.authToken = token
            }
        }
    }

    private func saveUserToDefaults(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: Keys.userData)
        }
    }
}
