import Foundation

protocol AuthApiServiceProtocol: Sendable {
    func login(email: String, password: String) async throws -> BaseResponse<LoginData>
    func loginApple(token: String) async throws -> BaseResponse<LoginData>
    func loginGoogle(token: String) async throws -> BaseResponse<LoginData>
    func register(name: String, email: String, password: String, confirmPassword: String, phoneNumber: String?) async throws -> BaseResponse<LoginData>
    func forgotPassword(email: String) async throws -> BaseResponse<String>
    func resetPassword(token: String, newPassword: String, confirmPassword: String) async throws -> BaseResponse<String>
    func verifyOtp(token: String?, phoneNumber: String) async throws -> BaseResponse<String>
    func resendOtp(phoneNumber: String) async throws -> BaseResponse<String>
    func setupPin(pin: String, confirmPin: String, token: String) async throws -> BaseResponse<String>
    func checkPin(pin: String, token: String) async throws -> StatusResponse
    func changePin(oldPin: String, newPin: String, confirmPin: String, token: String) async throws -> BaseResponse<String>
    func checkPassword(password: String, token: String) async throws -> StatusResponse
    func changePassword(newPassword: String, confirmPassword: String, token: String) async throws -> BaseResponse<String>
    func getProfile(token: String) async throws -> BaseResponse<ProfileData>
    func updateProfile(name: String?, phoneNumber: String?, token: String) async throws -> BaseResponse<ProfileData>
    func updateProfileWithImage(name: String, phoneNumber: String?, imageData: Data?, fileName: String?, existingImagePath: String?, deletePhoto: Bool, token: String) async throws -> BaseResponse<ProfileData>
    func getMe(token: String) async throws -> BaseResponse<ProfileData>
}

final class AuthApiService: AuthApiServiceProtocol {
    private let client = APIClient()

    func login(email: String, password: String) async throws -> BaseResponse<LoginData> {
        try await client.request(
            .post("auth/login", body: LoginRequest(email: email, password: password))
        )
    }

    func loginApple(token: String) async throws -> BaseResponse<LoginData> {
        try await client.request(
            .post("auth/login-apple", body: AppleLoginRequest(appleToken: token))
        )
    }

    func loginGoogle(token: String) async throws -> BaseResponse<LoginData> {
        try await client.request(
            .post("auth/login-google", body: GoogleLoginRequest(googleToken: token))
        )
    }

    func register(name: String, email: String, password: String, confirmPassword: String, phoneNumber: String?) async throws -> BaseResponse<LoginData> {
        try await client.request(
            .post("auth/register", body: RegisterRequest(
                name: name,
                email: email,
                password: password,
                confirmPassword: confirmPassword,
                phoneNumber: phoneNumber
            ))
        )
    }

    func forgotPassword(email: String) async throws -> BaseResponse<String> {
        try await client.request(
            .post("auth/forgot-password", body: ForgotPasswordRequest(email: email))
        )
    }

    func resetPassword(token: String, newPassword: String, confirmPassword: String) async throws -> BaseResponse<String> {
        try await client.request(
            .post("auth/reset-password", body: ResetPasswordRequest(
                token: token,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            ))
        )
    }

    func verifyOtp(token: String?, phoneNumber: String) async throws -> BaseResponse<String> {
        try await client.request(
            .post("auth/verify-otp", body: VerifyOtpRequest(token: token, phoneNumber: phoneNumber))
        )
    }

    func resendOtp(phoneNumber: String) async throws -> BaseResponse<String> {
        try await client.request(
            .post("auth/resend-otp", body: ResendOtpRequest(phoneNumber: phoneNumber))
        )
    }

    func setupPin(pin: String, confirmPin: String, token: String) async throws -> BaseResponse<String> {
        try await client.request(
            .post("auth/setup-pin", body: SetupPinRequest(pin: pin, confirmPin: confirmPin)),
            token: token
        )
    }

    func checkPin(pin: String, token: String) async throws -> StatusResponse {
        try await client.request(
            .post("auth/check-pin", body: CheckPinRequest(pin: pin)),
            token: token
        )
    }

    func changePin(oldPin: String, newPin: String, confirmPin: String, token: String) async throws -> BaseResponse<String> {
        try await client.request(
            .post("auth/change-pin", body: ChangePinRequest(oldPin: oldPin, newPin: newPin, confirmPin: confirmPin)),
            token: token
        )
    }

    func checkPassword(password: String, token: String) async throws -> StatusResponse {
        try await client.request(
            .post("auth/check-password", body: CheckPasswordRequest(password: password)),
            token: token
        )
    }

    func changePassword(newPassword: String, confirmPassword: String, token: String) async throws -> BaseResponse<String> {
        try await client.request(
            .post("auth/change-password", body: ChangePasswordRequest(newPassword: newPassword, confirmPassword: confirmPassword)),
            token: token
        )
    }

    func getProfile(token: String) async throws -> BaseResponse<ProfileData> {
        try await client.request(.get("auth/profile"), token: token)
    }

    func updateProfile(name: String?, phoneNumber: String?, token: String) async throws -> BaseResponse<ProfileData> {
        try await client.request(
            .put("auth/profile", body: UpdateProfileRequest(name: name, phoneNumber: phoneNumber)),
            token: token
        )
    }

    func updateProfileWithImage(
        name: String,
        phoneNumber: String?,
        imageData: Data?,
        fileName: String?,
        existingImagePath: String?,
        deletePhoto: Bool,
        token: String
    ) async throws -> BaseResponse<ProfileData> {
        var fields: [String: String] = ["name": name]
        if let phoneNumber { fields["phone_number"] = phoneNumber }

        if deletePhoto {
            // Don't send image field at all
        } else if let imageData, let fileName {
            // New photo will be uploaded as file
        } else if let existingImagePath {
            fields["image"] = existingImagePath
        }

        let fileField: (name: String, fileName: String, data: Data, mimeType: String)? = imageData.map { data in
            (name: "image", fileName: fileName ?? "photo.jpg", data: data, mimeType: "image/jpeg")
        }

        return try await client.multipartRequest(
            path: "auth/update-profile",
            method: .put,
            token: token,
            fields: fields,
            fileField: fileField
        )
    }

    func getMe(token: String) async throws -> BaseResponse<ProfileData> {
        try await client.request(.get("auth/me"), token: token)
    }
}
