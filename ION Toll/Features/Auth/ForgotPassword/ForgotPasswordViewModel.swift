import Foundation
import Observation

@Observable
@MainActor
final class ForgotPasswordViewModel {
    var email = ""
    var isLoading = false
    var errorMessage: String?
    var isSuccess = false

    func submit() async {
        guard !email.isEmpty else {
            errorMessage = "Email tidak boleh kosong."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            let message = try await repo.forgotPassword(email: email)
            if message.contains("berhasil") || message.contains("success") {
                isSuccess = true
            } else {
                errorMessage = message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
