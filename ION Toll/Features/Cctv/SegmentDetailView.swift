import SwiftUI

struct SegmentDetailView: View {
    let sectionId: String
    let sectionName: String
    let preselectedSegmentId: String

    @State private var viewModel: SegmentDetailViewModel
    @State private var showSegmentPicker = false

    init(sectionId: String, sectionName: String, preselectedSegmentId: String, sessionManager: SessionManager) {
        self.sectionId = sectionId
        self.sectionName = sectionName
        self.preselectedSegmentId = preselectedSegmentId
        self._viewModel = State(wrappedValue: SegmentDetailViewModel(sessionManager: sessionManager))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                shimmerLoading
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else {
                detailContent
            }
        }
        .navigationTitle(viewModel.sectionName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.initArgs(sectionId: sectionId, sectionName: sectionName, preselectedSegmentId: preselectedSegmentId)
        }
    }

    // MARK: - Content

    private var detailContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: IONDesign.Spacing.lg) {
                segmentDropdown
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                playerSection
                    .padding(.horizontal, 20)

                selectedCctvInfo
                    .padding(.horizontal, 20)

                cctvHorizontalList
                    .padding(.leading, 20)
            }
            .padding(.bottom, 32)
        }
    }

    // MARK: - Segment Dropdown

    private var segmentDropdown: some View {
        Menu {
            Button {
                Haptic.light()
                viewModel.selectSegment(nil)
            } label: {
                HStack {
                    if viewModel.selectedSegment == nil {
                        Image(systemName: "checkmark")
                    }
                    Text("Lihat semua")
                }
            }

            ForEach(viewModel.segmentList) { segment in
                Button {
                    Haptic.light()
                    viewModel.selectSegment(segment)
                } label: {
                    HStack {
                        if viewModel.selectedSegment?.id == segment.id {
                            Image(systemName: "checkmark")
                        }
                        Text(segment.segment)
                    }
                }
            }
        } label: {
            HStack {
                Text(viewModel.selectedSegment?.segment ?? "Lihat semua")
                    .font(.ionSubheadline.bold())
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator).opacity(0.5), lineWidth: 1))
        }
    }

    // MARK: - Player

    private var playerSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: IONDesign.Radius.lg)
                .fill(Color.black)
                .aspectRatio(16 / 9, contentMode: .fit)

            if let linkStream = viewModel.selectedCctv?.linkStream, !linkStream.isEmpty {
                HLSPlayerView(urlString: linkStream)
                    .clipShape(RoundedRectangle(cornerRadius: IONDesign.Radius.lg))
                    .aspectRatio(16 / 9, contentMode: .fit)
            } else {
                VStack(spacing: IONDesign.Spacing.sm) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("Stream tidak tersedia")
                        .font(.ionCaption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(16 / 9, contentMode: .fit)
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.selectedCctv?.id)
    }

    // MARK: - Selected CCTV Info

    private var selectedCctvInfo: some View {
        HStack(spacing: IONDesign.Spacing.md) {
            Circle()
                .fill(Color.brandPrimary.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay {
                    Image("ic_cctv")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.brandPrimary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.selectedCctv?.cctv ?? "Detail Lokasi")
                    .font(.ionSubheadline.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(viewModel.sectionName)
                    .font(.ionCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .animation(.spring(duration: 0.3), value: viewModel.selectedCctv?.id)
    }

    // MARK: - Horizontal CCTV List

    private var cctvHorizontalList: some View {
        VStack(alignment: .leading, spacing: IONDesign.Spacing.md) {
            HStack(spacing: 8) {
                Text("CCTV Tersedia")
                    .font(.ionHeadline.bold())

                if viewModel.isLoadingCctv {
                    ProgressView()
                        .frame(width: 16, height: 16)
                }
            }

            if viewModel.cctvList.isEmpty && !viewModel.isLoadingCctv {
                Text("Belum ada CCTV tersedia")
                    .font(.ionCaption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.cctvList) { item in
                            cctvCard(item)
                        }
                    }
                    .padding(.trailing, 20)
                }
            }
        }
    }

    private func cctvCard(_ item: CctvDetailItem) -> some View {
        let isSelected = viewModel.selectedCctv?.id == item.id

        return Button {
            viewModel.selectCctv(item)
        } label: {
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemBackground))
                        .aspectRatio(16 / 9, contentMode: .fill)

                    Image("ic_cctv")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(isSelected ? Color.brandPrimary : .secondary)
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 6) {
                    Image("ic_toll")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(Color.brandPrimary)

                    Text(item.cctv)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                        .foregroundStyle(isSelected ? Color.brandPrimary : .primary)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .frame(width: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.brandPrimary : Color(.separator).opacity(0.5),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .animation(.spring(duration: 0.25), value: isSelected)
        }
        .buttonStyle(PressScaleButtonStyle(scale: 0.96))
    }

    // MARK: - Loading & Error

    private var shimmerLoading: some View {
        VStack(spacing: IONDesign.Spacing.lg) {
            // Dropdown shimmer
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.separator).opacity(0.15))
                .frame(height: 48)
                .padding(.horizontal, 20)
                .padding(.top, 4)

            // Player shimmer
            RoundedRectangle(cornerRadius: IONDesign.Radius.lg)
                .fill(Color(.separator).opacity(0.15))
                .aspectRatio(16 / 9, contentMode: .fill)
                .padding(.horizontal, 20)

            // Info shimmer
            HStack(spacing: IONDesign.Spacing.md) {
                Circle()
                    .fill(Color(.separator).opacity(0.15))
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.separator).opacity(0.15))
                        .frame(width: 100, height: 14)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.separator).opacity(0.15))
                        .frame(width: 160, height: 12)
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            // Cards shimmer
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.separator).opacity(0.15))
                            .frame(width: 150, height: 120)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 8)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.red)
            Text(message)
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Coba lagi") {
                Haptic.light()
                viewModel.retry()
            }
            .font(.ionSubheadline.bold())
            .foregroundStyle(Color.brandPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}
