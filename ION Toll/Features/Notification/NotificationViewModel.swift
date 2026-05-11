import Foundation
import Observation

@Observable
@MainActor
final class NotificationViewModel {
    var items: [NotificationItem] = []
    var isLoading = true
    var errorMessage: String?
    var selectedTab: NotificationTab = .all
    var selectedFilter: NotificationFilter = .today
    var unreadCount: Int { items.filter { !$0.isRead }.count }

    private let repository: NotificationRepositoryProtocol
    private var currentPage = 1
    private var hasMorePages = true

    init(repository: NotificationRepositoryProtocol = NotificationRepository()) {
        self.repository = repository
    }

    var filteredItems: [NotificationItem] {
        switch selectedTab {
        case .all:
            return items
        case .unread:
            return items.filter { !$0.isRead }
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        hasMorePages = true

        do {
            items = try await repository.getNotifications(filter: selectedFilter.rawValue, page: 1)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadMore() async {
        guard !isLoading, hasMorePages else { return }
        currentPage += 1

        do {
            let newItems = try await repository.getNotifications(filter: selectedFilter.rawValue, page: currentPage)
            if newItems.isEmpty {
                hasMorePages = false
            } else {
                items.append(contentsOf: newItems)
            }
        } catch {
            currentPage -= 1
        }
    }

    func selectTab(_ tab: NotificationTab) {
        guard selectedTab != tab else { return }
        selectedTab = tab
    }

    func selectFilter(_ filter: NotificationFilter) {
        guard selectedFilter != filter else { return }
        selectedFilter = filter
        Task { await load() }
    }

    func markAsRead(_ id: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        guard !items[index].isRead else { return }

        items[index].isRead = true

        Task {
            try? await repository.markAsRead(id: id)
        }
    }

    func markAllAsRead() async {
        do {
            try await repository.markAllAsRead()
            for i in items.indices {
                items[i].isRead = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func retry() {
        Task { await load() }
    }
}
