import Foundation

// MARK: - Base Response

struct BaseResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
}

struct StatusResponse: Decodable {
    let success: Bool
    let message: String
}

// MARK: - Login

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginData: Decodable, Sendable {
    let id: String
    let name: String?
    let email: String?
    let phoneNumber: String?
    let profilePicture: String?
    let isVerified: Bool?
    let registrationCompleted: Bool?
    let pin: Bool?
    let needsProfileCompletion: Bool?
    let token: String?
}

// MARK: - Apple Login

struct AppleLoginRequest: Encodable {
    let appleToken: String
}

// MARK: - Google Login

struct GoogleLoginRequest: Encodable {
    let googleToken: String
}

// MARK: - Register

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let confirmPassword: String
    let phoneNumber: String?
}

// MARK: - Forgot Password

struct ForgotPasswordRequest: Encodable {
    let email: String
}

// MARK: - Reset Password

struct ResetPasswordRequest: Encodable {
    let token: String
    let newPassword: String
    let confirmPassword: String
}

// MARK: - OTP

struct VerifyOtpRequest: Encodable {
    let token: String?
    let phoneNumber: String
}

struct ResendOtpRequest: Encodable {
    let phoneNumber: String
}

// MARK: - PIN

struct SetupPinRequest: Encodable {
    let pin: String
    let confirmPin: String
}

struct CheckPinRequest: Encodable {
    let pin: String
}

struct ChangePinRequest: Encodable {
    let oldPin: String
    let newPin: String
    let confirmPin: String
}

// MARK: - Password

struct CheckPasswordRequest: Encodable {
    let password: String
}

struct ChangePasswordRequest: Encodable {
    let newPassword: String
    let confirmPassword: String
}

// MARK: - Profile

struct UpdateProfileRequest: Encodable {
    let name: String?
    let phoneNumber: String?
}

struct ProfileData: Decodable, Sendable {
    let id: String
    let name: String?
    let email: String?
    let phoneNumber: String?
    let profilePicture: String?
    let pathProfilePicture: String?
    let isVerified: Bool?
    let registrationCompleted: Bool?
    let pin: Bool?
    let needsProfileCompletion: Bool?
}
