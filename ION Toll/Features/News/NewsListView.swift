import SwiftUI

struct NewsListView: View {
    @State private var viewModel = NewsListViewModel()
    @State private var navigateToDetail: NewsItem?

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else if viewModel.filteredItems.isEmpty {
                    emptyState
                } else {
                    newsList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.systemBackground))
        .navigationTitle("ION News")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("Cari News", text: $viewModel.searchText)
                .font(.ionSubheadline)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
    }

    // MARK: - News List

    private var newsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(Array(viewModel.filteredItems.enumerated()), id: \.element.id) { index, item in
                    newsCard(item)
                        .staggeredFadeIn(index: index)
                        .onTapGesture {
                            Haptic.light()
                            navigateToDetail = item
                        }

                    if index < viewModel.filteredItems.count - 1 {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .navigationDestination(item: $navigateToDetail) { item in
            NewsDetailView(newsId: item.id)
        }
    }

    private func newsCard(_ item: NewsItem) -> some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    imagePlaceholder
                default:
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .overlay(ProgressView())
                }
            }
            .frame(height: 180)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.ion(15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(item.formattedDate)
                    .font(.ion(12))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private var imagePlaceholder: some View {
        ZStack {
            Color(.systemGray6)
            Image(systemName: "newspaper")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                viewModel.searchText.isEmpty
                    ? "Belum Ada News"
                    : "Tidak Ditemukan",
                systemImage: "newspaper"
            )
        } description: {
            Text(
                viewModel.searchText.isEmpty
                    ? "Berita terbaru akan muncul di sini."
                    : "Coba kata kunci lain."
            )
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    shimmerCard
                        .staggeredFadeIn(index: index)
                }
            }
            .padding(20)
        }
    }

    private var shimmerCard: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 180)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(height: 14)
                    .frame(maxWidth: 120)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Error

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
