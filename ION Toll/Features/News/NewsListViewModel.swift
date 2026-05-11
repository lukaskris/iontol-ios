import Foundation
import Observation

@Observable
@MainActor
final class NewsListViewModel {
    var items: [NewsItem] = []
    var isLoading = true
    var errorMessage: String?
    var searchText = ""

    private let repository: NewsRepositoryProtocol
    private var currentPage = 1
    private var hasMorePages = true

    init(repository: NewsRepositoryProtocol = NewsRepository()) {
        self.repository = repository
    }

    var filteredItems: [NewsItem] {
        if searchText.isEmpty { return items }
        return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        hasMorePages = true

        do {
            items = try await repository.getList(q: "", page: 1, perPage: 20)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadMore() async {
        guard !isLoading, hasMorePages else { return }
        currentPage += 1

        do {
            let newItems = try await repository.getList(q: "", page: currentPage, perPage: 20)
            if newItems.isEmpty {
                hasMorePages = false
            } else {
                items.append(contentsOf: newItems)
            }
        } catch {
            currentPage -= 1
        }
    }

    func retry() {
        Task { await load() }
    }
}
