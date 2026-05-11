import Foundation
import Observation

enum ChangePasswordStep {
    case verifyOld
    case setNew
}

@Observable
@MainActor
final class ChangePasswordViewModel {
    var oldPassword = ""
    var newPassword = ""
    var confirmPassword = ""
    var step: ChangePasswordStep = .verifyOld
    var isLoading = false
    var errorMessage: String?
    var isSuccess = false

    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    var isVerifyValid: Bool {
        !oldPassword.isEmpty
    }

    var isNewPasswordValid: Bool {
        newPassword.count >= 6 && newPassword == confirmPassword
    }

    func verifyOldPassword() async {
        guard isVerifyValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            guard let token = sessionManager.authToken else {
                errorMessage = "Sesi tidak valid."
                return
            }
            let valid = try await repo.checkPassword(password: oldPassword, token: token)
            if valid {
                step = .setNew
            } else {
                errorMessage = "Password lama tidak sesuai."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func changePassword() async {
        guard isNewPasswordValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            guard let token = sessionManager.authToken else {
                errorMessage = "Sesi tidak valid."
                return
            }
            let _ = try await repo.changePassword(newPassword: newPassword, confirmPassword: confirmPassword, token: token)
            isSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
