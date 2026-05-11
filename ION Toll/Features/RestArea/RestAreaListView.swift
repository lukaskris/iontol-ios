import SwiftUI

struct RestAreaListView: View {
    @State private var viewModel = RestAreaListViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var navigateToSearch = false
    @State private var selectedItem: RestAreaItem?

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else {
                contentView
            }
        }
        .navigationTitle("Rest Area")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    navigateToSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .navigationDestination(isPresented: $navigateToSearch) {
            RestAreaSearchView(items: viewModel.items) { item in
                selectedItem = item
            }
        }
        .navigationDestination(item: $selectedItem) { item in
            RestAreaDetailView(
                restAreaId: item.id,
                restAreaName: item.name,
                restAreaDirection: item.direction,
                restAreaDistance: item.distance,
                restAreaImageUrl: item.imageUrl,
                restAreaLatitude: item.latitude,
                restAreaLongitude: item.longitude
            )
        }
        .onAppear {
            viewModel.requestLocation()
        }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let first = viewModel.items.first {
                    recommendationSection(first)
                        .staggeredFadeIn(index: 0)
                }

                ForEach(Array(viewModel.items.dropFirst())) { item in
                    restAreaRow(item)
                        .staggeredFadeIn(index: 1)
                }
            }
        }
    }

    // MARK: - Recommendation

    private func recommendationSection(_ item: RestAreaItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rekomendasi")
                .font(.ionCallout)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            Button {
                selectedItem = item
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    restAreaImage(item.imageUrl, width: nil, height: 180, cornerRadius: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.ion(14, weight: .semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            Text(item.direction)
                                .font(.ion(13))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text(item.distance)
                                .font(.ion(11))
                                .foregroundStyle(.secondary)
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.brandPrimary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            Spacer().frame(height: 16)
        }
    }

    // MARK: - Row

    private func restAreaRow(_ item: RestAreaItem) -> some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                selectedItem = item
            } label: {
                HStack(spacing: 14) {
                    restAreaImage(item.imageUrl, width: 100, height: 70, cornerRadius: 8)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.ion(14, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(item.direction)
                            .font(.ion(13))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.brandPrimary)
                            Text(item.distance)
                                .font(.ion(11))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Image

    @ViewBuilder
    private func restAreaImage(_ url: String, width: CGFloat?, height: CGFloat, cornerRadius: CGFloat) -> some View {
        if let url = URL(string: url), !url.absoluteString.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    imagePlaceholder
                }
            }
            .frame(width: width, height: height)
            .clipped()
        } else {
            imagePlaceholder
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    private var imagePlaceholder: some View {
        ZStack {
            Color(.systemGray6)
            VStack(spacing: 4) {
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundStyle(.secondary)
                Text("Belum ada foto")
                    .font(.ionCaption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Loading & Error

    private var loadingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 100, height: 14)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 180)

                ForEach(0..<4, id: \.self) { _ in
                    Divider()
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                            .frame(width: 100, height: 70)
                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray6))
                                .frame(width: 140, height: 16)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray6))
                                .frame(width: 100, height: 14)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray6))
                                .frame(width: 120, height: 12)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Gagal Memuat", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Coba Lagi") {
                viewModel.retry()
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color.brandPrimary)
        }
    }
}
