import Foundation

protocol NotificationRepositoryProtocol: Sendable {
    func getNotifications(filter: String, page: Int) async throws -> [NotificationItem]
    func markAsRead(id: String) async throws
    func markAllAsRead() async throws
}

final class NotificationRepository: NotificationRepositoryProtocol {
    private let api: NotificationApiServiceProtocol

    init(api: NotificationApiServiceProtocol = NotificationApiService()) {
        self.api = api
    }

    func getNotifications(filter: String, page: Int) async throws -> [NotificationItem] {
        let response = try await api.getNotifications(filter: filter, page: page)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return data.map { $0.toItem() }
    }

    func markAsRead(id: String) async throws {
        _ = try await api.markAsRead(id: id)
    }

    func markAllAsRead() async throws {
        _ = try await api.markAllAsRead()
    }
}
