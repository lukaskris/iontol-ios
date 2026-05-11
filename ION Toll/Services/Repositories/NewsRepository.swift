import Foundation

protocol NewsRepositoryProtocol: Sendable {
    func getList(q: String, page: Int, perPage: Int) async throws -> [NewsItem]
    func getDetail(id: String) async throws -> (item: NewsItem, content: String, relatedNews: [NewsItem])
}

final class NewsRepository: NewsRepositoryProtocol {
    private let api: NewsApiServiceProtocol

    init(api: NewsApiServiceProtocol = NewsApiService()) {
        self.api = api
    }

    func getList(q: String, page: Int, perPage: Int) async throws -> [NewsItem] {
        let response = try await api.getNews(q: q, page: page, perPage: perPage)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return data.map { $0.toItem() }
    }

    func getDetail(id: String) async throws -> (item: NewsItem, content: String, relatedNews: [NewsItem]) {
        let response = try await api.getNewsDetail(id: id)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }

        let item = NewsItem(
            id: data.id,
            title: data.title ?? "",
            imageUrl: data.image ?? "",
            publishedAt: Date()
        )
        let related: [NewsItem] = (data.relevanNews ?? []).map { $0.toItem() }
        return (item: item, content: data.content ?? "", relatedNews: related)
    }
}
