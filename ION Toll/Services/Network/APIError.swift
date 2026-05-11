import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(underlying: Error)
    case unauthorized
    case serverError(message: String)
    case decodingError(underlying: Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL tidak valid."
        case .networkError(let error):
            return error.localizedDescription
        case .unauthorized:
            return "Sesi Anda telah berakhir. Silakan masuk kembali."
        case .serverError(let message):
            return message
        case .decodingError:
            return "Terjadi kesalahan saat memproses data."
        case .invalidResponse:
            return "Respons server tidak valid."
        case .httpError(_, let message):
            return message
        case .unknown:
            return "Terjadi kesalahan yang tidak diketahui."
        }
    }
}
