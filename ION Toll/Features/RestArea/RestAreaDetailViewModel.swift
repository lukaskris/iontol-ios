import Foundation
import Observation

@Observable
@MainActor
final class RestAreaDetailViewModel {
    var restArea: RestAreaItem?
    var selectedTab: DetailTab = .tenant
    var tenants: [TenantItem] = []
    var filteredTenants: [TenantItem] = []
    var categories: [CategoryItem] = []
    var selectedCategoryId: String?
    var facilities: [FacilityItem] = []
    var parkingAreas: [ParkingAreaItem] = []
    var images: [String] = []
    var isLoading = true
    var errorMessage: String?

    private let repository = RestAreaRepository()
    private var currentId = ""

    func load(id: String, distance: String) {
        guard currentId != id else { return }
        currentId = id
        isLoading = true
        errorMessage = nil

        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadTenants(id: id, distance: distance) }
                group.addTask { await self.loadFacilities(id: id) }
                group.addTask { await self.loadParkings(id: id) }
                group.addTask { await self.loadCategories() }
            }
            isLoading = false
        }
    }

    func toggleTenant(_ id: String) {
        for i in tenants.indices {
            if tenants[i].id == id { tenants[i].isExpanded.toggle() }
        }
        applyCategoryFilter()
    }

    func toggleFacility(_ id: String) {
        for i in facilities.indices {
            if facilities[i].id == id { facilities[i].isExpanded.toggle() }
        }
    }

    func toggleParking(_ id: String) {
        for i in parkingAreas.indices {
            if parkingAreas[i].id == id { parkingAreas[i].isExpanded.toggle() }
        }
    }

    func selectCategory(_ id: String?) {
        selectedCategoryId = id
        applyCategoryFilter()
    }

    // MARK: - Private

    private func loadTenants(id: String, distance: String) async {
        do {
            let dto = try await repository.getDetail(id: id, view: "tenants")
            let urls = dto.images?.compactMap { $0.imageUrl ?? $0.imagePath }.filter { !$0.isEmpty } ?? []
            let list = dto.tenants?.map { $0.toItem() } ?? []
            images = urls
            tenants = list
            filteredTenants = list
            if restArea == nil {
                restArea = RestAreaItem(
                    id: dto.id, name: dto.name,
                    direction: dto.endCity ?? "", distance: distance,
                    imageUrl: urls.first ?? "",
                    latitude: dto.latitude ?? 0, longitude: dto.longitude ?? 0
                )
            }
        } catch {}
    }

    private func loadFacilities(id: String) async {
        do {
            let dto = try await repository.getDetail(id: id, view: "facility")
            facilities = dto.facility?.map { $0.toItem() } ?? []
        } catch {}
    }

    private func loadParkings(id: String) async {
        do {
            let dto = try await repository.getDetail(id: id, view: "parkings")
            parkingAreas = dto.parkings?.map { $0.toItem() } ?? []
        } catch {}
    }

    private func loadCategories() async {
        do {
            categories = try await repository.getCategories()
        } catch {}
    }

    private func applyCategoryFilter() {
        guard let catId = selectedCategoryId,
              let catName = categories.first(where: { $0.id == catId })?.name else {
            filteredTenants = tenants
            return
        }
        filteredTenants = tenants.filter { $0.category.caseInsensitiveCompare(catName) == .orderedSame }
    }
}
