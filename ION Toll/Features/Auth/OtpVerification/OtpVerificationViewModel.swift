import Foundation
import Observation

@Observable
@MainActor
final class OtpVerificationViewModel {
    var otp = ""
    var isLoading = false
    var errorMessage: String?
    var isVerified = false
    var resendCooldown: Int = 300
    var canResend: Bool { resendCooldown == 0 }

    let phoneNumber: String
    private let authToken: String?
    private let sessionManager: SessionManager
    let router: AppRouter

    private nonisolated(unsafe) var timer: Task<Void, Never>?

    // Matches Android: normalize to 62xxxxxxxxx
    private var formattedPhoneNumber: String {
        let digits = phoneNumber.filter { $0.isNumber }
        if digits.hasPrefix("62") {
            return digits
        } else if digits.hasPrefix("0") {
            return "62" + digits.dropFirst()
        } else {
            return "62" + digits
        }
    }

    init(phoneNumber: String, token: String?, sessionManager: SessionManager, router: AppRouter) {
        self.phoneNumber = phoneNumber
        self.authToken = token
        self.sessionManager = sessionManager
        self.router = router
        startCooldown()
    }

    var isOtpValid: Bool {
        otp.count == 5 && otp.allSatisfy(\.isNumber)
    }

    // MARK: - Verify OTP

    func verify() async {
        guard isOtpValid, !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            let _ = try await repo.verifyOtp(token: otp, phoneNumber: formattedPhoneNumber)

            isVerified = true

            // Update user verification status in session
            if let user = sessionManager.currentUser {
                sessionManager.updateUser(User(
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    phoneNumber: formattedPhoneNumber,
                    profilePicture: user.profilePicture,
                    isVerified: true,
                    registrationCompleted: user.registrationCompleted,
                    hasPin: user.hasPin,
                    needsProfileCompletion: user.needsProfileCompletion,
                    isGuest: user.isGuest
                ))
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Resend OTP

    func resendOtp() async {
        guard canResend else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            let _ = try await repo.resendOtp(phoneNumber: formattedPhoneNumber)
            startCooldown()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Cooldown Timer

    private func startCooldown() {
        resendCooldown = 300
        timer?.cancel()
        timer = Task { @MainActor in
            while resendCooldown > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                resendCooldown -= 1
            }
        }
    }

    deinit {
        timer?.cancel()
    }
}
