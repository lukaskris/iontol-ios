import Foundation
import Observation

@Observable
@MainActor
final class RegisterViewModel {
    var name = ""
    var email = ""
    var phone = ""
    var password = ""
    var confirmPassword = ""
    var isLoading = false
    var errorMessage: String?

    var onNavigateToOtp: ((String, String?) -> Void)?

    private let sessionManager: SessionManager
    private let router: AppRouter

    init(sessionManager: SessionManager, router: AppRouter) {
        self.sessionManager = sessionManager
        self.router = router
    }

    // MARK: - Validation (matches Android rules)

    var showEmailError: Bool { !email.isEmpty }
    var showPhoneError: Bool { !phone.isEmpty }
    var showPasswordError: Bool { !password.isEmpty }
    var showConfirmPasswordError: Bool { !confirmPassword.isEmpty }

    var validatedEmailError: String? {
        guard showEmailError else { return nil }
        if email.isEmpty { return "Email tidak boleh kosong" }
        let pattern = "[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        if email.range(of: pattern, options: .regularExpression) == nil { return "Format email tidak valid" }
        return nil
    }

    var validatedPhoneError: String? {
        guard showPhoneError else { return nil }
        let digits = phone.filter(\.isNumber)
        if digits.isEmpty { return "No. HP tidak boleh kosong" }
        if digits.count < 8 { return "Nomor telepon minimal 8 digit" }
        return nil
    }

    var validatedPasswordError: String? {
        guard showPasswordError else { return nil }
        if password.isEmpty { return "Password tidak boleh kosong" }
        if password.count < 6 { return "Password minimal 6 karakter" }
        return nil
    }

    var validatedConfirmPasswordError: String? {
        guard showConfirmPasswordError else { return nil }
        if confirmPassword.isEmpty { return "Konfirmasi password tidak boleh kosong" }
        if confirmPassword != password { return "Password tidak cocok" }
        return nil
    }

    var isFormValid: Bool {
        !name.isEmpty
            && name.count >= 2
            && validatedEmailError == nil
            && validatedPhoneError == nil
            && validatedPasswordError == nil
            && validatedConfirmPasswordError == nil
    }

    // MARK: - Phone Formatting (matches Android: strip leading 0, prepend 62)

    var formattedPhoneNumber: String {
        let digits = phone.filter(\.isNumber)
        let stripped = digits.hasPrefix("0") ? String(digits.dropFirst()) : digits
        return "62\(stripped)"
    }

    // MARK: - Register

    func register() async {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let apiService = AuthApiService()
            let response = try await apiService.register(
                name: name,
                email: email,
                password: password,
                confirmPassword: confirmPassword,
                phoneNumber: formattedPhoneNumber
            )

            guard let loginData = response.data else {
                errorMessage = response.message
                return
            }

            let user = User(from: loginData)
            let token = loginData.token ?? ""

            await sessionManager.saveSession(user: user, token: token)

            // After registration, go to OTP verification (matches Android)
            router.replace(with: .otpVerification(phoneNumber: formattedPhoneNumber, token: token))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
