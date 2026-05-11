import Foundation

struct SegmentItem: Identifiable, Sendable, Hashable {
    let id: String
    let segment: String

    init(from dto: SegmentItemDto) {
        self.id = dto.id
        self.segment = dto.segment ?? "Segment \(dto.id)"
    }
}
