import Foundation

// MARK: - CCTV List (GET cctv)

struct CctvDto: Decodable, Sendable {
    let id: String
    let section: String?
    let distance: Double?
    let latitude: Double?
    let longitude: Double?
    let name: String?
    let segmentId: String?
    let segmentName: String?
    let status: String?
    let thumbnailUrl: String?
}

// MARK: - Segment (GET cctv/segment/{id})

struct SegmentDataDto: Decodable, Sendable {
    let id: String?
    let section: String?
    let segments: [SegmentItemDto]?
}

struct SegmentItemDto: Decodable, Sendable {
    let id: String
    let segment: String?
}

// MARK: - CCTV Detail (GET cctv/{id})

struct CctvDetailDataDto: Decodable, Sendable {
    let id: String?
    let section: String?
    let cctvs: [CctvDetailItemDto]?
}

struct CctvDetailItemDto: Decodable, Sendable {
    let id: String
    let cctv: String?
    let latitude: Double?
    let longitude: Double?
    let linkStream: String?
}
