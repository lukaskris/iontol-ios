import Foundation
import Observation

@Observable
@MainActor
final class SegmentDetailViewModel {
    var segmentList: [SegmentItem] = []
    var selectedSegment: SegmentItem?
    var cctvList: [CctvDetailItem] = []
    var selectedCctv: CctvDetailItem?
    var sectionName = ""
    var isLoading = false
    var isLoadingCctv = false
    var errorMessage: String?

    private var sectionId = ""
    private let repository: CctvRepositoryProtocol
    private let sessionManager: SessionManager

    init(repository: CctvRepositoryProtocol = CctvRepository(), sessionManager: SessionManager) {
        self.repository = repository
        self.sessionManager = sessionManager
    }

    func initArgs(sectionId: String, sectionName: String, preselectedSegmentId: String = "") {
        self.sectionId = sectionId
        self.sectionName = sectionName
        loadSegments(preselectedSegmentId: preselectedSegmentId)
    }

    func selectSegment(_ segment: SegmentItem?) {
        selectedSegment = segment
        loadCctvDetail()
    }

    func selectCctv(_ cctv: CctvDetailItem) {
        Haptic.medium()
        selectedCctv = cctv
    }

    func retry() {
        loadSegments(preselectedSegmentId: selectedSegment?.id ?? "")
    }

    private func loadSegments(preselectedSegmentId: String = "") {
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                let segments = try await repository.getSegmentsForCctv(cctvId: sectionId, token: sessionManager.authToken)
                let preselected = preselectedSegmentId.isEmpty
                    ? nil
                    : segments.first { $0.id == preselectedSegmentId }

                segmentList = segments
                selectedSegment = preselected
                loadCctvDetail()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func loadCctvDetail() {
        isLoadingCctv = true
        selectedCctv = nil

        Task {
            defer { isLoadingCctv = false }
            do {
                let list = try await repository.getCctvDetail(
                    id: sectionId,
                    segmentId: selectedSegment?.id,
                    token: sessionManager.authToken
                )
                cctvList = list
                selectedCctv = list.first
            } catch {
                cctvList = []
                selectedCctv = nil
            }
        }
    }
}
