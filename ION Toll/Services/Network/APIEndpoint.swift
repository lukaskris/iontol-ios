import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let body: Encodable?
    let queryItems: [URLQueryItem]?

    static let baseURL = "https://vlbj.egoq.lyr.id/api/"

    var url: URL? {
        var components = URLComponents(string: APIEndpoint.baseURL)
        components?.path += path
        if let queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }

    static func post(_ path: String, body: Encodable? = nil) -> APIEndpoint {
        APIEndpoint(path: path, method: .post, body: body, queryItems: nil)
    }

    static func get(_ path: String, queryItems: [URLQueryItem]? = nil) -> APIEndpoint {
        APIEndpoint(path: path, method: .get, body: nil, queryItems: queryItems)
    }

    static func put(_ path: String, body: Encodable? = nil) -> APIEndpoint {
        APIEndpoint(path: path, method: .put, body: body, queryItems: nil)
    }

    static func patch(_ path: String, body: Encodable? = nil) -> APIEndpoint {
        APIEndpoint(path: path, method: .patch, body: body, queryItems: nil)
    }
}
