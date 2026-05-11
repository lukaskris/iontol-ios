import Foundation

protocol CctvRepositoryProtocol: Sendable {
    func getCctvList(perPage: Int, page: Int, longitude: Double, latitude: Double, token: String?) async throws -> [CctvItem]
    func getCctvDetail(id: String, segmentId: String?, token: String?) async throws -> [CctvDetailItem]
    func getSegmentsForCctv(cctvId: String, token: String?) async throws -> [SegmentItem]
}

final class CctvRepository: CctvRepositoryProtocol {
    private let api: CctvApiServiceProtocol

    init(api: CctvApiServiceProtocol = CctvApiService()) {
        self.api = api
    }

    func getCctvList(perPage: Int = 20, page: Int = 1, longitude: Double, latitude: Double, token: String?) async throws -> [CctvItem] {
        let response = try await api.getCctvList(perPage: perPage, page: page, longitude: longitude, latitude: latitude, token: token)
        return (response.data ?? []).map { CctvItem(from: $0) }
    }

    func getCctvDetail(id: String, segmentId: String? = nil, token: String?) async throws -> [CctvDetailItem] {
        let response = try await api.getCctvDetail(id: id, segmentId: segmentId, token: token)
        return (response.data?.cctvs ?? []).map { CctvDetailItem(from: $0) }
    }

    func getSegmentsForCctv(cctvId: String, token: String?) async throws -> [SegmentItem] {
        let response = try await api.getSegmentsForCctv(cctvId: cctvId, token: token)
        return (response.data?.segments ?? []).map { SegmentItem(from: $0) }
    }
}
