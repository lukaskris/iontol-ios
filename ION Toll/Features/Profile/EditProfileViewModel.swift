import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class EditProfileViewModel {
    var name = ""
    var phone = ""
    var email = ""
    var isLoading = false
    var errorMessage: String?
    var isSuccess = false

    var selectedImageData: Data?
    var selectedImagePreview: UIImage?
    var shouldDeletePhoto = false

    let sessionManager: SessionManager

    var hasExistingPhoto: Bool {
        guard let url = sessionManager.currentUser?.profilePicture, !url.isEmpty else { return false }
        return true
    }

    var hasPhotoChange: Bool {
        selectedImageData != nil || shouldDeletePhoto
    }

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        if let user = sessionManager.currentUser {
            self.name = user.name
            self.email = user.email
            self.phone = stripCountryCode(user.phoneNumber)
        }
    }

    var isFormValid: Bool {
        !name.isEmpty
    }

    func resetState() {
        errorMessage = nil
        isSuccess = false
        selectedImageData = nil
        selectedImagePreview = nil
        shouldDeletePhoto = false
        if let user = sessionManager.currentUser {
            name = user.name
            email = user.email
            phone = stripCountryCode(user.phoneNumber)
        }
    }

    func setSelectedImage(_ image: UIImage) {
        selectedImagePreview = image
        selectedImageData = image.jpegData(compressionQuality: 0.8)
        shouldDeletePhoto = false
    }

    func markDeletePhoto() {
        shouldDeletePhoto = true
        selectedImageData = nil
        selectedImagePreview = nil
    }

    func save() async {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let repo = AuthRepository()
            guard let token = sessionManager.authToken else {
                errorMessage = "Sesi tidak valid."
                return
            }

            let fullPhone = phone.isEmpty ? nil : "62\(phone)"

            try await repo.updateProfileWithImage(
                name: name,
                phoneNumber: fullPhone,
                imageData: selectedImageData,
                fileName: selectedImageData != nil ? "profile.jpg" : nil,
                existingImagePath: sessionManager.currentUser?.pathProfilePicture,
                deletePhoto: shouldDeletePhoto,
                token: token
            )

            let updatedUser = try await repo.getMe(token: token)
            sessionManager.updateUser(updatedUser)
            isSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func stripCountryCode(_ phone: String?) -> String {
        guard let phone else { return "" }
        var stripped = phone
        if stripped.hasPrefix("+62") { stripped = String(stripped.dropFirst(3)) }
        else if stripped.hasPrefix("62") { stripped = String(stripped.dropFirst(2)) }
        return stripped
    }
}
