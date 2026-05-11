import Foundation

struct User: Codable, Sendable, Identifiable, Equatable {
    let id: String
    var name: String
    var email: String
    var phoneNumber: String?
    var profilePicture: String?
    var pathProfilePicture: String?
    var isVerified: Bool
    var registrationCompleted: Bool
    var hasPin: Bool
    var needsProfileCompletion: Bool
    var isGuest: Bool

    static var placeholder: User {
        User(
            id: UUID().uuidString,
            name: "John Doe",
            email: "user@example.com",
            phoneNumber: nil,
            profilePicture: nil,
            isVerified: true,
            registrationCompleted: true,
            hasPin: true,
            needsProfileCompletion: false,
            isGuest: false
        )
    }

    static var guest: User {
        User(
            id: "guest",
            name: "Tamu",
            email: "",
            phoneNumber: nil,
            profilePicture: nil,
            isVerified: false,
            registrationCompleted: false,
            hasPin: false,
            needsProfileCompletion: false,
            isGuest: true
        )
    }

    init(
        id: String,
        name: String,
        email: String,
        phoneNumber: String? = nil,
        profilePicture: String? = nil,
        pathProfilePicture: String? = nil,
        isVerified: Bool = false,
        registrationCompleted: Bool = false,
        hasPin: Bool = false,
        needsProfileCompletion: Bool = false,
        isGuest: Bool = false
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePicture = profilePicture
        self.pathProfilePicture = pathProfilePicture
        self.isVerified = isVerified
        self.registrationCompleted = registrationCompleted
        self.hasPin = hasPin
        self.needsProfileCompletion = needsProfileCompletion
        self.isGuest = isGuest
    }
}

extension User {
    init(from dto: LoginData) {
        self.id = dto.id
        self.name = dto.name ?? ""
        self.email = dto.email ?? ""
        self.phoneNumber = dto.phoneNumber
        self.profilePicture = dto.profilePicture
        self.pathProfilePicture = nil
        self.isVerified = dto.isVerified ?? false
        self.registrationCompleted = dto.registrationCompleted ?? false
        self.hasPin = dto.pin ?? false
        self.needsProfileCompletion = dto.needsProfileCompletion ?? false
        self.isGuest = false
    }

    init(from dto: ProfileData) {
        self.id = dto.id
        self.name = dto.name ?? ""
        self.email = dto.email ?? ""
        self.phoneNumber = dto.phoneNumber
        self.profilePicture = dto.profilePicture
        self.pathProfilePicture = dto.pathProfilePicture
        self.isVerified = dto.isVerified ?? false
        self.registrationCompleted = dto.registrationCompleted ?? false
        self.hasPin = dto.pin ?? false
        self.needsProfileCompletion = dto.needsProfileCompletion ?? false
        self.isGuest = false
    }
}
