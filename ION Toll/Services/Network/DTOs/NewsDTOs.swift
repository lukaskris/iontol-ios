import Foundation

struct NewsDto: Decodable, Sendable {
    let id: String
    let title: String?
    let image: String?
    let publishedAt: String?
}

struct NewsDetailDto: Decodable, Sendable {
    let id: String
    let title: String?
    let content: String?
    let image: String?
    let relevanNews: [RelatedNewsDto]?
}

struct RelatedNewsDto: Decodable, Sendable {
    let id: String
    let title: String?
    let image: String?
    let publishedAt: String?
}

// MARK: - Mappers

private let newsDateISO: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
}()

private let newsDateFallback: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return f
}()

private func parseNewsDate(_ string: String?) -> Date {
    guard let string else { return Date() }
    return newsDateISO.date(from: string)
        ?? newsDateFallback.date(from: string)
        ?? Date()
}

extension NewsDto {
    func toItem() -> NewsItem {
        NewsItem(
            id: id,
            title: title ?? "",
            imageUrl: image ?? "",
            publishedAt: parseNewsDate(publishedAt)
        )
    }
}

extension RelatedNewsDto {
    func toItem() -> NewsItem {
        NewsItem(
            id: id,
            title: title ?? "",
            imageUrl: image ?? "",
            publishedAt: parseNewsDate(publishedAt)
        )
    }
}
