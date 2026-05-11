import Foundation

// MARK: - Rest Area List DTOs

struct RestAreaDto: Decodable, Sendable {
    let id: String
    let name: String
    let latitude: Double?
    let longitude: Double?
    let startCity: String?
    let endCity: String?
    let images: [RestAreaImageDto]?
    let distance: Double?
}

struct RestAreaImageDto: Decodable, Sendable {
    let id: String
    let image: String?
    let url: String?
}

// MARK: - Rest Area Detail DTOs

struct RestAreaDetailDto: Decodable, Sendable {
    let id: String
    let name: String
    let startCity: String?
    let endCity: String?
    let section: String?
    let latitude: Double?
    let longitude: Double?
    let businessEntities: String?
    let images: [RestAreaDetailImageDto]?
    let tenants: [TenantDto]?
    let parkings: [ParkingDto]?
    let facility: [FacilityDto]?
}

struct RestAreaDetailImageDto: Decodable, Sendable {
    let id: String
    let imagePath: String?
    let imageUrl: String?
}

struct TenantDto: Decodable, Sendable {
    let id: String
    let tenantName: String?
    let startTime: String?
    let endTime: String?
    let longitude: Double?
    let latitude: Double?
    let logo: String?
    let category: String?
    let images: [TenantImageDto]?
    let logoUrl: String?
}

struct TenantImageDto: Decodable, Sendable {
    let id: String
    let image: String?
    let imageUrl: String?
}

struct ParkingDto: Decodable, Sendable {
    let id: String
    let name: String?
    let status: String?
    let available: Int?
    let unavailable: Int?
}

struct FacilityDto: Decodable, Sendable {
    let id: String
    let name: String?
    let latitude: Double?
    let longitude: Double?
    let imageUrl: String?
}

struct CategoryDto: Decodable, Sendable {
    let id: String
    let name: String
}

// MARK: - Mappers

extension RestAreaDto {
    func toItem() -> RestAreaItem {
        let dir = [startCity, endCity]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " - ")

        let imageUrl = images?.first?.url ?? images?.first?.image ?? ""

        return RestAreaItem(
            id: id,
            name: name,
            direction: dir,
            distance: (distance ?? 0).distanceString,
            imageUrl: imageUrl,
            latitude: latitude ?? 0,
            longitude: longitude ?? 0
        )
    }
}

extension TenantDto {
    func toItem() -> TenantItem {
        let start = startTime ?? ""
        let end = endTime ?? ""
        let hours = (!start.isEmpty && !end.isEmpty) ? "\(start) - \(end)" : ""

        return TenantItem(
            id: id,
            name: tenantName ?? "",
            category: category ?? "",
            operationalHours: hours,
            imageUrls: images?.compactMap { $0.imageUrl ?? $0.image }.filter { !$0.isEmpty } ?? [],
            logoUrl: logoUrl ?? logo ?? "",
            latitude: latitude ?? 0,
            longitude: longitude ?? 0,
            isExpanded: false
        )
    }
}

extension FacilityDto {
    func toItem() -> FacilityItem {
        FacilityItem(
            id: id,
            name: name ?? "",
            imageUrl: imageUrl ?? "",
            latitude: latitude ?? 0,
            longitude: longitude ?? 0,
            isExpanded: false
        )
    }
}

extension ParkingDto {
    func toItem() -> ParkingAreaItem {
        ParkingAreaItem(
            id: id,
            name: name ?? "",
            status: status ?? "",
            available: available ?? 0,
            unavailable: unavailable ?? 0,
            isExpanded: false
        )
    }
}

extension CategoryDto {
    func toItem() -> CategoryItem {
        CategoryItem(id: id, name: name)
    }
}
