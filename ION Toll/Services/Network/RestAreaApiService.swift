import Foundation

protocol RestAreaApiServiceProtocol: Sendable {
    func getRestAreaList(latitude: Double, longitude: Double, query: String?) async throws -> BaseResponse<[RestAreaDto]>
    func getRestAreaDetail(id: String, view: String?) async throws -> BaseResponse<RestAreaDetailDto>
    func getCategories() async throws -> BaseResponse<[CategoryDto]>
}

final class RestAreaApiService: RestAreaApiServiceProtocol {
    private let client = APIClient()

    func getRestAreaList(latitude: Double, longitude: Double, query: String?) async throws -> BaseResponse<[RestAreaDto]> {
        var items = [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude))
        ]
        if let query, !query.isEmpty {
            items.append(URLQueryItem(name: "q", value: query))
        }
        return try await client.request(.get("rest-area", queryItems: items))
    }

    func getRestAreaDetail(id: String, view: String?) async throws -> BaseResponse<RestAreaDetailDto> {
        var items: [URLQueryItem] = []
        if let view { items.append(URLQueryItem(name: "view", value: view)) }
        return try await client.request(.get("rest-area/\(id)", queryItems: items.isEmpty ? nil : items))
    }

    func getCategories() async throws -> BaseResponse<[CategoryDto]> {
        try await client.request(.get("rest-area/category"))
    }
}
