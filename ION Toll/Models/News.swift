import Foundation

struct NewsItem: Identifiable, Hashable {
    let id: String
    let title: String
    let imageUrl: String
    let publishedAt: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        let calendar = Calendar.current

        if calendar.isDateInToday(publishedAt) {
            formatter.dateFormat = "HH:mm"
            return "Hari ini, \(formatter.string(from: publishedAt))"
        }
        if calendar.isDateInYesterday(publishedAt) {
            formatter.dateFormat = "HH:mm"
            return "Kemarin, \(formatter.string(from: publishedAt))"
        }
        if Calendar.current.isDate(publishedAt, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateFormat = "d MMM yyyy"
        }
        return formatter.string(from: publishedAt)
    }
}
