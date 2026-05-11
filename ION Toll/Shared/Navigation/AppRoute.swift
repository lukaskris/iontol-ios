import Foundation

enum AppRoute: Hashable {
    // Auth
    case onboarding
    case login
    case register
    case forgotPassword
    case resetPassword(token: String)
    case phoneInput(userId: String)
    case otpVerification(phoneNumber: String, token: String?)
    case pinSetup(userId: String)

    // Main
    case mainTab

    // Profile
    case editProfile
    case changePassword
    case changePin

    // CCTV
    case cctvMap
    case segmentList
    case segmentDetail(segmentId: String, segmentName: String)
    case cctvDetail(cctvId: String, cctvName: String)
}

extension AppRoute {
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case (.onboarding, .onboarding): true
        case (.login, .login): true
        case (.register, .register): true
        case (.forgotPassword, .forgotPassword): true
        case (.resetPassword(let a), .resetPassword(let b)): a == b
        case (.phoneInput(let a), .phoneInput(let b)): a == b
        case (.otpVerification(let a1, let b1), .otpVerification(let a2, let b2)): a1 == a2 && b1 == b2
        case (.pinSetup(let a), .pinSetup(let b)): a == b
        case (.mainTab, .mainTab): true
        case (.editProfile, .editProfile): true
        case (.changePassword, .changePassword): true
        case (.changePin, .changePin): true
        case (.cctvMap, .cctvMap): true
        case (.segmentList, .segmentList): true
        case (.segmentDetail(let a1, let b1), .segmentDetail(let a2, let b2)): a1 == a2 && b1 == b2
        case (.cctvDetail(let a1, let b1), .cctvDetail(let a2, let b2)): a1 == a2 && b1 == b2
        default: false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .onboarding: hasher.combine("onboarding")
        case .login: hasher.combine("login")
        case .register: hasher.combine("register")
        case .forgotPassword: hasher.combine("forgotPassword")
        case .resetPassword(let token): hasher.combine("resetPassword"); hasher.combine(token)
        case .phoneInput(let id): hasher.combine("phoneInput"); hasher.combine(id)
        case .otpVerification(let phone, let token): hasher.combine("otp"); hasher.combine(phone); hasher.combine(token)
        case .pinSetup(let id): hasher.combine("pinSetup"); hasher.combine(id)
        case .mainTab: hasher.combine("mainTab")
        case .editProfile: hasher.combine("editProfile")
        case .changePassword: hasher.combine("changePassword")
        case .changePin: hasher.combine("changePin")
        case .cctvMap: hasher.combine("cctvMap")
        case .segmentList: hasher.combine("segmentList")
        case .segmentDetail(let id, _): hasher.combine("segmentDetail"); hasher.combine(id)
        case .cctvDetail(let id, _): hasher.combine("cctvDetail"); hasher.combine(id)
        }
    }
}
