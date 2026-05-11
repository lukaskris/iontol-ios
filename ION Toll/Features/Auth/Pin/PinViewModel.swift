import Foundation
import Observation

enum PinStep {
    case create
    case confirm
}

@Observable
@MainActor
final class PinViewModel {
    var pin = ""
    var confirmPin = ""
    var step: PinStep = .create
    var isLoading = false
    var errorMessage: String?

    let pinLength = 6

    var onComplete: (() -> Void)?

    private let sessionManager: SessionManager
    private let router: AppRouter
    let isSkippable: Bool

    init(sessionManager: SessionManager, router: AppRouter, isSkippable: Bool = false) {
        self.sessionManager = sessionManager
        self.router = router
        self.isSkippable = isSkippable
    }

    var isPinComplete: Bool {
        if step == .create {
            return pin.count == pinLength
        } else {
            return confirmPin.count == pinLength
        }
    }

    var title: String {
        switch step {
        case .create: return "Buat PIN"
        case .confirm: return "Konfirmasi PIN"
        }
    }

    var subtitle: String {
        switch step {
        case .create: return "Buat 6 digit PIN untuk melindungi akun dan pembayaran Anda"
        case .confirm: return "Masukkan kembali PIN Anda"
        }
    }

    var currentPinCount: Int {
        step == .create ? pin.count : confirmPin.count
    }

    func addDigit(_ digit: String) {
        if step == .create {
            guard pin.count < pinLength else { return }
            pin += digit
        } else {
            guard confirmPin.count < pinLength else { return }
            confirmPin += digit
        }
    }

    func deleteDigit() {
        if step == .create {
            guard !pin.isEmpty else { return }
            pin.removeLast()
        } else {
            guard !confirmPin.isEmpty else { return }
            confirmPin.removeLast()
        }
    }

    func submit() {
        if step == .create {
            guard isPinComplete else { return }
            step = .confirm
        } else {
            guard isPinComplete else { return }
            Task { await submitPin() }
        }
    }

    func skip() {
        onComplete?()
    }

    private func submitPin() async {
        guard pin == confirmPin else {
            errorMessage = "PIN tidak cocok. Silakan coba lagi."
            confirmPin = ""
            pin = ""
            step = .create
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            guard let token = sessionManager.authToken else {
                errorMessage = "Sesi tidak valid."
                return
            }
            let _ = try await repo.setupPin(pin: pin, confirmPin: confirmPin, token: token)

            // Update user
            if var user = sessionManager.currentUser {
                let updated = User(
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    phoneNumber: user.phoneNumber,
                    profilePicture: user.profilePicture,
                    isVerified: user.isVerified,
                    registrationCompleted: true,
                    hasPin: true,
                    needsProfileCompletion: user.needsProfileCompletion,
                    isGuest: user.isGuest
                )
                sessionManager.updateUser(updated)
            }

            onComplete?()
        } catch {
            errorMessage = error.localizedDescription
            confirmPin = ""
            pin = ""
            step = .create
        }
    }
}
