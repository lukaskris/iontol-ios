import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class NewsDetailViewModel {
    var title: String = ""
    var imageUrl: String = ""
    var content: AttributedString = AttributedString("")
    var formattedDate: String = ""
    var relatedNews: [NewsItem] = []
    var isLoading = true
    var errorMessage: String?

    private let repository: NewsRepositoryProtocol
    private var newsId: String

    init(newsId: String, repository: NewsRepositoryProtocol = NewsRepository()) {
        self.repository = repository
        self.newsId = newsId
        Task { await load() }
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await repository.getDetail(id: newsId)
            title = result.item.title
            imageUrl = result.item.imageUrl

            let cleanedHTML = Self.stripStyles(from: result.content)

            if let data = cleanedHTML.data(using: .utf8),
               let nsAttr = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
               ) {
                let defaultParagraph = NSMutableParagraphStyle()
                defaultParagraph.headIndent = 0
                defaultParagraph.tailIndent = 0
                defaultParagraph.firstLineHeadIndent = 0
                defaultParagraph.paragraphSpacing = 8
                defaultParagraph.lineSpacing = 2

                let fullRange = NSRange(location: 0, length: nsAttr.length)
                let mutableAttr = NSMutableAttributedString(attributedString: nsAttr)
                mutableAttr.addAttribute(.paragraphStyle, value: defaultParagraph, range: fullRange)
                mutableAttr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: fullRange)
                mutableAttr.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)

                content = AttributedString(mutableAttr)
            }

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "id_ID")
            formatter.dateFormat = "d MMMM yyyy, HH:mm"
            formattedDate = formatter.string(from: result.item.publishedAt)

            relatedNews = result.relatedNews
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private static func stripStyles(from html: String) -> String {
        var result = html
        // Remove <style>...</style> blocks
        result = result.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        // Remove style="..." attributes
        result = result.replacingOccurrences(of: " style=\"[^\"]*\"", with: "", options: .regularExpression)
        // Remove class="..." attributes
        result = result.replacingOccurrences(of: " class=\"[^\"]*\"", with: "", options: .regularExpression)
        // Wrap in clean template
        return """
        <!DOCTYPE html>
        <html><body>
        \(result)
        </body></html>
        """
    }
}
