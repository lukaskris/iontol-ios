import Foundation

protocol AuthRepositoryProtocol: Sendable {
    func login(email: String, password: String) async throws -> User
    func loginApple(token: String) async throws -> User
    func register(name: String, email: String, password: String, confirmPassword: String, phoneNumber: String?) async throws -> User
    func forgotPassword(email: String) async throws -> String
    func resetPassword(token: String, newPassword: String, confirmPassword: String) async throws -> String
    func verifyOtp(token: String?, phoneNumber: String) async throws -> String
    func resendOtp(phoneNumber: String) async throws -> String
    func setupPin(pin: String, confirmPin: String, token: String) async throws -> String
    func checkPin(pin: String, token: String) async throws -> Bool
    func changePin(oldPin: String, newPin: String, confirmPin: String, token: String) async throws -> String
    func checkPassword(password: String, token: String) async throws -> Bool
    func changePassword(newPassword: String, confirmPassword: String, token: String) async throws -> String
    func getProfile(token: String) async throws -> User
    func updateProfile(name: String?, phoneNumber: String?, token: String) async throws -> User
    func updateProfileWithImage(name: String, phoneNumber: String?, imageData: Data?, fileName: String?, existingImagePath: String?, deletePhoto: Bool, token: String) async throws
    func getMe(token: String) async throws -> User
}

final class AuthRepository: AuthRepositoryProtocol {
    private let api: AuthApiServiceProtocol

    init(api: AuthApiServiceProtocol = AuthApiService()) {
        self.api = api
    }

    func login(email: String, password: String) async throws -> User {
        let response = try await api.login(email: email, password: password)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return User(from: data)
    }

    func loginApple(token: String) async throws -> User {
        let response = try await api.loginApple(token: token)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return User(from: data)
    }

    func register(name: String, email: String, password: String, confirmPassword: String, phoneNumber: String?) async throws -> User {
        let response = try await api.register(
            name: name, email: email,
            password: password, confirmPassword: confirmPassword,
            phoneNumber: phoneNumber
        )
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return User(from: data)
    }

    func forgotPassword(email: String) async throws -> String {
        let response = try await api.forgotPassword(email: email)
        return response.message
    }

    func resetPassword(token: String, newPassword: String, confirmPassword: String) async throws -> String {
        let response = try await api.resetPassword(token: token, newPassword: newPassword, confirmPassword: confirmPassword)
        return response.message
    }

    func verifyOtp(token: String?, phoneNumber: String) async throws -> String {
        let response = try await api.verifyOtp(token: token, phoneNumber: phoneNumber)
        return response.message
    }

    func resendOtp(phoneNumber: String) async throws -> String {
        let response = try await api.resendOtp(phoneNumber: phoneNumber)
        return response.message
    }

    func setupPin(pin: String, confirmPin: String, token: String) async throws -> String {
        let response = try await api.setupPin(pin: pin, confirmPin: confirmPin, token: token)
        return response.message
    }

    func checkPin(pin: String, token: String) async throws -> Bool {
        let response = try await api.checkPin(pin: pin, token: token)
        return response.success
    }

    func changePin(oldPin: String, newPin: String, confirmPin: String, token: String) async throws -> String {
        let response = try await api.changePin(oldPin: oldPin, newPin: newPin, confirmPin: confirmPin, token: token)
        return response.message
    }

    func checkPassword(password: String, token: String) async throws -> Bool {
        let response = try await api.checkPassword(password: password, token: token)
        return response.success
    }

    func changePassword(newPassword: String, confirmPassword: String, token: String) async throws -> String {
        let response = try await api.changePassword(newPassword: newPassword, confirmPassword: confirmPassword, token: token)
        return response.message
    }

    func getProfile(token: String) async throws -> User {
        let response = try await api.getProfile(token: token)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return User(from: data)
    }

    func updateProfile(name: String?, phoneNumber: String?, token: String) async throws -> User {
        let response = try await api.updateProfile(name: name, phoneNumber: phoneNumber, token: token)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return User(from: data)
    }

    func updateProfileWithImage(
        name: String,
        phoneNumber: String?,
        imageData: Data?,
        fileName: String?,
        existingImagePath: String?,
        deletePhoto: Bool,
        token: String
    ) async throws {
        let response = try await api.updateProfileWithImage(
            name: name,
            phoneNumber: phoneNumber,
            imageData: imageData,
            fileName: fileName,
            existingImagePath: existingImagePath,
            deletePhoto: deletePhoto,
            token: token
        )
        guard response.success else {
            throw APIError.serverError(message: response.message)
        }
    }

    func getMe(token: String) async throws -> User {
        let response = try await api.getMe(token: token)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return User(from: data)
    }
}
