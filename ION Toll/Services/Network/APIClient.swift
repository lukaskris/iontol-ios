import Foundation
import Pulse

actor APIClient {
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let store = LoggerStore.shared

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        let enc = JSONEncoder()
        enc.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = enc

        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = dec
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        token: String? = nil
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // CORS / required headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("mobile", forHTTPHeaderField: "x-client-type")
        request.setValue("https://vlbj.egoq.lyr.id", forHTTPHeaderField: "Origin")
        request.setValue("https://vlbj.egoq.lyr.id/", forHTTPHeaderField: "Referer")

        // Auth token
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Body
        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            // Log failed request to Pulse
            store.storeRequest(request, response: nil, error: error, data: nil)
            throw APIError.networkError(underlying: error)
        }

        // Log completed request + response to Pulse
        store.storeRequest(request, response: response, error: nil, data: data)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        if httpResponse.statusCode >= 400 {
            if let errorBody = try? decoder.decode(BaseResponse<String>.self, from: data) {
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorBody.message)
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: "Kesalahan server (\(httpResponse.statusCode))")
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(underlying: error)
        }
    }

    func multipartRequest<T: Decodable>(
        path: String,
        method: HTTPMethod = .put,
        token: String? = nil,
        fields: [String: String] = [:],
        fileField: (name: String, fileName: String, data: Data, mimeType: String)? = nil
    ) async throws -> T {
        let urlString = APIEndpoint.baseURL + path
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        for (key, value) in fields {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            body.append(Data("\(value)\r\n".utf8))
        }

        if let file = fileField {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n".utf8))
            body.append(Data("Content-Type: \(file.mimeType)\r\n\r\n".utf8))
            body.append(file.data)
            body.append(Data("\r\n".utf8))
        }

        body.append(Data("--\(boundary)--\r\n".utf8))

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("mobile", forHTTPHeaderField: "x-client-type")
        request.setValue("https://vlbj.egoq.lyr.id", forHTTPHeaderField: "Origin")
        request.setValue("https://vlbj.egoq.lyr.id/", forHTTPHeaderField: "Referer")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = body

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            store.storeRequest(request, response: nil, error: error, data: nil)
            throw APIError.networkError(underlying: error)
        }

        store.storeRequest(request, response: response, error: nil, data: data)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        if httpResponse.statusCode >= 400 {
            if let errorBody = try? decoder.decode(BaseResponse<String>.self, from: data) {
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorBody.message)
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: "Kesalahan server (\(httpResponse.statusCode))")
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(underlying: error)
        }
    }
}
