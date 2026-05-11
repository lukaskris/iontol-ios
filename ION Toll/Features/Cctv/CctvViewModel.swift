import Foundation
import Observation
import CoreLocation

@Observable
@MainActor
final class CctvViewModel {
    var cctvItems: [CctvItem] = []
    var isLoading = false
    var errorMessage: String?
    var searchQuery = ""

    // Map mode - section selection & detail
    var selectedCctvItem: CctvItem?
    var cctvDetailList: [CctvDetailItem] = []
    var selectedDetailCctv: CctvDetailItem?
    var isLoadingDetail = false

    private var page = 1
    private var hasMore = true
    private var isLoadingMore = false

    var filteredList: [CctvItem] {
        if searchQuery.isEmpty {
            return cctvItems
        }
        return cctvItems.filter { $0.section.localizedCaseInsensitiveContains(searchQuery) }
    }

    private let repository: CctvRepositoryProtocol
    let sessionManager: SessionManager

    init(repository: CctvRepositoryProtocol = CctvRepository(), sessionManager: SessionManager) {
        self.repository = repository
        self.sessionManager = sessionManager
    }

    func loadCctvList(latitude: Double = 0, longitude: Double = 0) async {
        isLoading = true
        errorMessage = nil
        page = 1
        hasMore = true
        defer { isLoading = false }

        do {
            let items = try await repository.getCctvList(
                perPage: 20, page: page,
                longitude: longitude, latitude: latitude,
                token: sessionManager.authToken
            )
            cctvItems = items
            hasMore = items.count >= 20
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMore(latitude: Double = 0, longitude: Double = 0) async {
        guard !isLoadingMore && hasMore else { return }
        isLoadingMore = true
        page += 1
        defer { isLoadingMore = false }

        do {
            let items = try await repository.getCctvList(
                perPage: 20, page: page,
                longitude: longitude, latitude: latitude,
                token: sessionManager.authToken
            )
            cctvItems += items
            hasMore = items.count >= 20
        } catch {
            page -= 1
        }
    }

    func loadCctvDetail(for item: CctvItem) async {
        selectedCctvItem = item
        cctvDetailList = []
        selectedDetailCctv = nil
        isLoadingDetail = true

        do {
            let details = try await repository.getCctvDetail(
                id: item.id, segmentId: nil, token: sessionManager.authToken
            )
            cctvDetailList = details
            if let first = details.first {
                selectedDetailCctv = first
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingDetail = false
    }

    func clearSelection() {
        selectedCctvItem = nil
        cctvDetailList = []
        selectedDetailCctv = nil
    }
}
