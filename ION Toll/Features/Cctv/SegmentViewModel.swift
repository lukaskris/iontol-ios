import Foundation
import Observation

@Observable
@MainActor
final class SegmentViewModel {
    var segments: [SegmentItem] = []
    var isLoading = false
    var errorMessage: String?
    let sectionName: String

    let cctvId: String
    private let repository: CctvRepositoryProtocol
    let sessionManager: SessionManager

    init(cctvId: String, sectionName: String, repository: CctvRepositoryProtocol = CctvRepository(), sessionManager: SessionManager) {
        self.cctvId = cctvId
        self.sectionName = sectionName
        self.repository = repository
        self.sessionManager = sessionManager
    }

    func loadSegments() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            segments = try await repository.getSegmentsForCctv(cctvId: cctvId, token: sessionManager.authToken)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
