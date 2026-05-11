import Foundation

enum AppError: LocalizedError {
    case api(APIError)
    case validation(String)
    case sessionExpired
    case pinMismatch
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .api(let error):
            return error.errorDescription
        case .validation(let message):
            return message
        case .sessionExpired:
            return "Sesi Anda telah berakhir. Silakan masuk kembali."
        case .pinMismatch:
            return "PIN tidak cocok. Silakan coba lagi."
        case .networkUnavailable:
            return "Tidak ada koneksi internet. Silakan periksa jaringan Anda."
        }
    }
}
