import Foundation

protocol NotificationApiServiceProtocol: Sendable {
    func getNotifications(filter: String, page: Int) async throws -> BaseResponse<[NotificationDto]>
    func markAsRead(id: String) async throws -> StatusResponse
    func markAllAsRead() async throws -> StatusResponse
}

final class NotificationApiService: NotificationApiServiceProtocol {
    private let client = APIClient()

    func getNotifications(filter: String, page: Int) async throws -> BaseResponse<[NotificationDto]> {
        let items = [
            URLQueryItem(name: "filter", value: filter),
            URLQueryItem(name: "per_page", value: "20"),
            URLQueryItem(name: "page", value: String(page))
        ]
        return try await client.request(.get("notifications", queryItems: items))
    }

    func markAsRead(id: String) async throws -> StatusResponse {
        try await client.request(.patch("notifications/\(id)/read"))
    }

    func markAllAsRead() async throws -> StatusResponse {
        try await client.request(.patch("notifications/read-all"))
    }
}
