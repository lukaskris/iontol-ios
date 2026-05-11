import Foundation
import CoreLocation

// MARK: - Domain Models

struct RestAreaItem: Identifiable, Hashable {
    let id: String
    let name: String
    let direction: String
    let distance: String
    let imageUrl: String
    let latitude: Double
    let longitude: Double
}

struct TenantItem: Identifiable {
    let id: String
    let name: String
    let category: String
    let operationalHours: String
    let imageUrls: [String]
    let logoUrl: String
    let latitude: Double
    let longitude: Double
    var isExpanded: Bool
}

struct FacilityItem: Identifiable {
    let id: String
    let name: String
    let imageUrl: String
    let latitude: Double
    let longitude: Double
    var isExpanded: Bool
}

struct ParkingAreaItem: Identifiable {
    let id: String
    let name: String
    let status: String
    let available: Int
    let unavailable: Int
    var totalSlot: Int { available + unavailable }
    var isExpanded: Bool
    var isAvailable: Bool { available > 0 }
}

struct CategoryItem: Identifiable, Hashable {
    let id: String
    let name: String
}

enum DetailTab: CaseIterable {
    case tenant, facility, parking

    var label: String {
        switch self {
        case .tenant: "Tenant"
        case .facility: "Fasilitas Umum"
        case .parking: "Area Parkir"
        }
    }
}

// MARK: - Distance Formatting

extension Double {
    var distanceString: String {
        if self < 1000 {
            "\(Int(self)) m dari lokasi Anda"
        } else {
            String(format: "%.1f km dari lokasi Anda", self / 1000)
        }
    }
}
