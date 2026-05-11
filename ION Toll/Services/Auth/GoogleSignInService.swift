import Foundation
import GoogleSignIn

@MainActor
final class GoogleSignInService {

    func signIn() async throws -> String {
        guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            throw APIError.serverError(message: "Tidak dapat menampilkan halaman login Google.")
        }

        let result: GIDSignInResult = try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingVC,
                hint: nil,
                completion: { signInResult, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let signInResult {
                        continuation.resume(returning: signInResult)
                    } else {
                        continuation.resume(
                            throwing: APIError.serverError(message: "Gagal mendapatkan Google ID token.")
                        )
                    }
                }
            )
        }

        guard let idToken = result.user.idToken?.tokenString else {
            throw APIError.serverError(message: "Gagal mendapatkan Google ID token.")
        }

        return idToken
    }
}
