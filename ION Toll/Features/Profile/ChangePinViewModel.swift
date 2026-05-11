import Foundation
import Observation

enum ChangePinStep: Int {
    case verifyOld = 0
    case setNew = 1
    case confirm = 2
}

@Observable
@MainActor
final class ChangePinViewModel {
    var oldPin = ""
    var newPin = ""
    var confirmPin = ""
    var step: ChangePinStep = .verifyOld
    var isLoading = false
    var errorMessage: String?
    var isSuccess = false

    let pinLength = 6
    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    var title: String {
        switch step {
        case .verifyOld: return "Masukkan PIN Lama"
        case .setNew: return "PIN Baru"
        case .confirm: return "Konfirmasi PIN"
        }
    }

    var currentPinCount: Int {
        switch step {
        case .verifyOld: return oldPin.count
        case .setNew: return newPin.count
        case .confirm: return confirmPin.count
        }
    }

    func addDigit(_ digit: String) {
        switch step {
        case .verifyOld:
            guard oldPin.count < pinLength else { return }
            oldPin += digit
            if oldPin.count == pinLength {
                Task { await verifyOldPin() }
            }
        case .setNew:
            guard newPin.count < pinLength else { return }
            newPin += digit
            if newPin.count == pinLength {
                step = .confirm
            }
        case .confirm:
            guard confirmPin.count < pinLength else { return }
            confirmPin += digit
            if confirmPin.count == pinLength {
                Task { await submitChangePin() }
            }
        }
    }

    func deleteDigit() {
        switch step {
        case .verifyOld:
            guard !oldPin.isEmpty else { return }
            oldPin.removeLast()
        case .setNew:
            guard !newPin.isEmpty else { return }
            newPin.removeLast()
        case .confirm:
            guard !confirmPin.isEmpty else { return }
            confirmPin.removeLast()
        }
    }

    private func verifyOldPin() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            guard let token = sessionManager.authToken else {
                errorMessage = "Sesi tidak valid."
                return
            }
            let valid = try await repo.checkPin(pin: oldPin, token: token)
            if valid {
                step = .setNew
            } else {
                errorMessage = "PIN lama tidak sesuai."
                oldPin = ""
            }
        } catch {
            errorMessage = error.localizedDescription
            oldPin = ""
        }
    }

    private func submitChangePin() async {
        guard newPin == confirmPin else {
            errorMessage = "PIN tidak cocok."
            newPin = ""
            confirmPin = ""
            step = .setNew
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
            let _ = try await repo.changePin(oldPin: oldPin, newPin: newPin, confirmPin: confirmPin, token: token)
            isSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            oldPin = ""
            newPin = ""
            confirmPin = ""
            step = .verifyOld
        }
    }
}
