import Foundation

protocol CctvApiServiceProtocol: Sendable {
    func getCctvList(perPage: Int, page: Int, longitude: Double, latitude: Double, token: String?) async throws -> BaseResponse<[CctvDto]>
    func getCctvDetail(id: String, segmentId: String?, token: String?) async throws -> BaseResponse<CctvDetailDataDto>
    func getSegmentsForCctv(cctvId: String, token: String?) async throws -> BaseResponse<SegmentDataDto>
}

final class CctvApiService: CctvApiServiceProtocol {
    private let client = APIClient()

    func getCctvList(perPage: Int = 20, page: Int = 1, longitude: Double, latitude: Double, token: String?) async throws -> BaseResponse<[CctvDto]> {
        let queryItems = [
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "latitude", value: String(latitude)),
        ]
        return try await client.request(.get("cctv", queryItems: queryItems), token: token)
    }

    func getCctvDetail(id: String, segmentId: String? = nil, token: String?) async throws -> BaseResponse<CctvDetailDataDto> {
        var queryItems: [URLQueryItem]?
        if let segmentId {
            queryItems = [URLQueryItem(name: "segment_id", value: segmentId)]
        }
        return try await client.request(.get("cctv/\(id)", queryItems: queryItems), token: token)
    }

    func getSegmentsForCctv(cctvId: String, token: String?) async throws -> BaseResponse<SegmentDataDto> {
        try await client.request(.get("cctv/segment/\(cctvId)"), token: token)
    }
}
