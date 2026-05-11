import Foundation

protocol NewsApiServiceProtocol: Sendable {
    func getNews(q: String, page: Int, perPage: Int) async throws -> BaseResponse<[NewsDto]>
    func getNewsDetail(id: String) async throws -> BaseResponse<NewsDetailDto>
}

final class NewsApiService: NewsApiServiceProtocol {
    private let client = APIClient()

    func getNews(q: String, page: Int, perPage: Int) async throws -> BaseResponse<[NewsDto]> {
        let items = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page))
        ]
        return try await client.request(.get("news", queryItems: items))
    }

    func getNewsDetail(id: String) async throws -> BaseResponse<NewsDetailDto> {
        try await client.request(.get("news/\(id)"))
    }
}
