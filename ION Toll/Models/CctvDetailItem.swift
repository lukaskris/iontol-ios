import Foundation
import CoreLocation

struct CctvDetailItem: Identifiable, Sendable {
    let id: String
    let cctv: String
    let latitude: Double
    let longitude: Double
    let linkStream: String

    var isOnline: Bool { !linkStream.isEmpty }
    var hasStream: Bool { !linkStream.isEmpty }

    init(from dto: CctvDetailItemDto) {
        self.id = dto.id
        self.cctv = dto.cctv ?? "CCTV \(dto.id)"
        self.latitude = dto.latitude ?? 0
        self.longitude = dto.longitude ?? 0
        self.linkStream = dto.linkStream ?? ""
    }
}
