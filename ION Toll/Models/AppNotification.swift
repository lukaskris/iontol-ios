import Foundation

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let body: String
    let iconType: String
    let imageUrl: String?
    let referenceId: String?
    let referenceType: String?
    var isRead: Bool
    let createdAt: Date

    var timeAgo: String {
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)

        if interval < 60 { return "Baru saja" }
        if interval < 3600 { return "\(Int(interval / 60)) menit lalu" }
        if interval < 86400 { return "\(Int(interval / 3600)) jam lalu" }
        if interval < 172800 { return "Kemarin" }
        if interval < 604800 { return "\(Int(interval / 86400)) hari lalu" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        if Calendar.current.isDate(createdAt, equalTo: now, toGranularity: .year) {
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateFormat = "d MMM yyyy"
        }
        return formatter.string(from: createdAt)
    }
}

enum NotificationFilter: String, CaseIterable {
    case today = "today"
    case yesterday = "yesterday"
    case last7Days = "7days"
    case last30Days = "30days"

    var label: String {
        switch self {
        case .today: "Hari Ini"
        case .yesterday: "Kemarin"
        case .last7Days: "7 Hari Terakhir"
        case .last30Days: "30 Hari Terakhir"
        }
    }
}

enum NotificationTab: String, CaseIterable {
    case all = "all"
    case unread = "unread"

    var label: String {
        switch self {
        case .all: "Semua"
        case .unread: "Belum Dibaca"
        }
    }
}
