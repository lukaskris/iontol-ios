import SwiftUI

struct SegmentView: View {
    @State private var viewModel: SegmentViewModel
    @State private var selectedSegment: SegmentItem?
    @State private var viewAll = false

    init(cctvId: String, sectionName: String, sessionManager: SessionManager) {
        self._viewModel = State(wrappedValue: SegmentViewModel(
            cctvId: cctvId,
            sectionName: sectionName,
            sessionManager: sessionManager
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                shimmerLoading
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else {
                segmentContent
            }
        }
        .navigationTitle(viewModel.sectionName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadSegments()
        }
        .navigationDestination(item: $selectedSegment) { segment in
            SegmentDetailView(
                sectionId: viewModel.cctvId,
                sectionName: viewModel.sectionName,
                preselectedSegmentId: segment.id,
                sessionManager: viewModel.sessionManager
            )
        }
        .navigationDestination(isPresented: $viewAll) {
            SegmentDetailView(
                sectionId: viewModel.cctvId,
                sectionName: viewModel.sectionName,
                preselectedSegmentId: "",
                sessionManager: viewModel.sessionManager
            )
        }
    }

    // MARK: - Content

    private var segmentContent: some View {
        VStack(spacing: 0) {
            if viewModel.segments.isEmpty {
                emptyState
            } else {
                viewAllButton

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 6) {
                        ForEach(Array(viewModel.segments.enumerated()), id: \.element.id) { index, segment in
                            segmentRow(segment, index: index)
                        }
                    }
                }
            }
        }
    }

    private var viewAllButton: some View {
        Button {
            Haptic.light()
            viewAll = true
        } label: {
            Text("Lihat semua segment")
                .font(.ionSubheadline.bold())
                .foregroundStyle(Color.brandPrimary)
        }
        .buttonStyle(PressScaleButtonStyle(scale: 0.96))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private func segmentRow(_ segment: SegmentItem, index: Int) -> some View {
        Button {
            Haptic.light()
            withAnimation(.spring(duration: 0.3)) {
                selectedSegment = segment
            }
        } label: {
            HStack(spacing: 14) {
                Image("ic_toll")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(Color.brandPrimary)

                Text(segment.segment)
                    .font(.ionSubheadline.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressScaleButtonStyle(scale: 0.97))
        .padding(.horizontal, 20)
        .staggeredFadeIn(index: index)
    }

    // MARK: - States

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "road.lanes")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Belum ada segment tersedia")
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 40)
    }

    private var shimmerLoading: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 6) {
                ForEach(0..<6, id: \.self) { index in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Color(.separator).opacity(0.2))
                            .frame(width: 22, height: 22)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.separator).opacity(0.2))
                            .frame(width: [180, 140, 200][index % 3], height: 16)
                        Spacer()
                        Circle()
                            .fill(Color(.separator).opacity(0.2))
                            .frame(width: 16, height: 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 8)
        }
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
                Task { await viewModel.loadSegments() }
            }
            .font(.ionSubheadline.bold())
            .foregroundStyle(Color.brandPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}
