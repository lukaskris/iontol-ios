import Foundation
import CoreLocation

struct CctvItem: Identifiable, Sendable, Hashable {
    let id: String
    let section: String
    let distance: Double
    let latitude: Double?
    let longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        if let lat = latitude, let lon = longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    init(from dto: CctvDto) {
        self.id = dto.id
        self.section = dto.section ?? dto.name ?? "CCTV \(dto.id)"
        self.distance = dto.distance ?? 0
        self.latitude = dto.latitude
        self.longitude = dto.longitude
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CctvItem, rhs: CctvItem) -> Bool {
        lhs.id == rhs.id
    }
}
