import Foundation
import Observation

@Observable
@MainActor
final class ResetPasswordViewModel {
    var newPassword = ""
    var confirmPassword = ""
    var isLoading = false
    var errorMessage: String?
    var isSuccess = false

    let resetToken: String

    init(token: String) {
        self.resetToken = token
    }

    var isFormValid: Bool {
        newPassword.count >= 6 && newPassword == confirmPassword
    }

    func submit() async {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            let _ = try await repo.resetPassword(
                token: resetToken,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )
            isSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
