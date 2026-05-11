import SwiftUI

struct NewsDetailView: View {
    @State private var viewModel: NewsDetailViewModel
    @State private var navigateToDetail: NewsItem?

    init(newsId: String) {
        self._viewModel = State(wrappedValue: NewsDetailViewModel(newsId: newsId))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else {
                detailContent
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $navigateToDetail) { item in
            NewsDetailView(newsId: item.id)
        }
    }

    // MARK: - Detail Content

    private var detailContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                heroImage
                    .staggeredFadeIn(index: 0)

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.title)
                        .font(.ion(16, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(viewModel.formattedDate)
                        .font(.ion(13))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .staggeredFadeIn(index: 1)

                Divider()
                    .padding(.leading, 24)
                    .padding(.trailing, 24)
                    .padding(.vertical, 8)

                Text(viewModel.content)
                    .font(.ion(14))
                    .foregroundStyle(.primary)
                    .tint(Color.brandPrimary)
                    .padding(.horizontal, 24)
                    .staggeredFadeIn(index: 2)

                if !viewModel.relatedNews.isEmpty {
                    relatedSection
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                        .staggeredFadeIn(index: 3)
                }

                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Hero Image

    private var heroImage: some View {
        AsyncImage(url: URL(string: viewModel.imageUrl)) { phase in
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
        .frame(height: 260)
        .clipped()
    }

    private var imagePlaceholder: some View {
        ZStack {
            Color(.systemGray6)
            Image(systemName: "newspaper")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Related News

    private var relatedSection: some View {
        VStack(spacing: 12) {
            Text("News Lainnya")
                .font(.ionHeadline.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(viewModel.relatedNews) { item in
                    relatedCard(item)
                }
            }
        }
    }

    private func relatedCard(_ item: NewsItem) -> some View {
        Button {
            Haptic.light()
            navigateToDetail = item
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: item.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color(.systemGray6)
                            .overlay(
                                Image(systemName: "newspaper")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.secondary)
                            )
                    default:
                        Color(.systemGray6)
                            .overlay(ProgressView())
                    }
                }
                .frame(height: 100)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(item.title)
                    .font(.ion(13, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.formattedDate)
                    .font(.ion(11))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(PressScaleButtonStyle(scale: 0.96))
    }

    // MARK: - Loading

    private var loadingView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 260)

                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                        .frame(height: 24)
                        .frame(maxWidth: .infinity)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                        .frame(height: 14)
                        .frame(maxWidth: 140)
                }
                .padding(20)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray6))
                            .frame(height: 14)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Gagal Memuat", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Coba Lagi") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color.brandPrimary)
        }
    }
}
