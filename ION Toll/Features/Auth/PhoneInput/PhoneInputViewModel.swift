import Foundation
import Observation

@Observable
@MainActor
final class PhoneInputViewModel {
    var phone = ""
    var isLoading = false
    var errorMessage: String?

    private let sessionManager: SessionManager
    private let router: AppRouter

    init(sessionManager: SessionManager, router: AppRouter) {
        self.sessionManager = sessionManager
        self.router = router
    }

    // Matches Android: strip leading 0, prepend 62
    var formattedPhone: String {
        let digits = phone.filter(\.isNumber)
        if digits.hasPrefix("0") {
            return "62" + digits.dropFirst()
        } else if digits.hasPrefix("62") {
            return digits
        }
        return "62" + digits
    }

    var isFormValid: Bool {
        phone.filter(\.isNumber).count >= 8
    }

    // Matches Android: calls resend-otp API, then navigates to OTP on success
    func submit() async {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            let _ = try await repo.resendOtp(phoneNumber: formattedPhone)

            router.navigate(to: .otpVerification(phoneNumber: formattedPhone, token: sessionManager.authToken))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
