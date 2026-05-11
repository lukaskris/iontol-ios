import Foundation

struct NotificationDto: Decodable, Sendable {
    let id: String
    let title: String?
    let body: String?
    let iconType: String?
    let imageUrl: String?
    let referenceId: String?
    let referenceType: String?
    let isRead: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, body
        case iconType = "icon_type"
        case imageUrl = "image_url"
        case referenceId = "reference_id"
        case referenceType = "reference_type"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

extension NotificationDto {
    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let fallbackFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()

    func toItem() -> NotificationItem {
        let parsedDate: Date
        if let dateString = createdAt {
            parsedDate = Self.isoFormatter.date(from: dateString)
                ?? Self.fallbackFormatter.date(from: dateString)
                ?? Date()
        } else {
            parsedDate = Date()
        }

        return NotificationItem(
            id: id,
            title: title ?? "",
            body: body ?? "",
            iconType: iconType ?? "info",
            imageUrl: imageUrl,
            referenceId: referenceId,
            referenceType: referenceType,
            isRead: isRead ?? false,
            createdAt: parsedDate
        )
    }
}
