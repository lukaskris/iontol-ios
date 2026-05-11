import SwiftUI

struct NotificationView: View {
    @State private var viewModel = NotificationViewModel()
    @State private var showReadAllAlert = false

    var body: some View {
        VStack(spacing: 0) {
            filterBar

            Divider()

            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else if viewModel.filteredItems.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Notifikasi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        Task { await viewModel.markAllAsRead() }
                    } label: {
                        Label("Tandai Semua Dibaca", systemImage: "checkmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.brandPrimary)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        VStack(spacing: 0) {
            tabRow
            dateFilterRow
        }
    }

    private var tabRow: some View {
        HStack(spacing: 0) {
            ForEach(NotificationTab.allCases, id: \.self) { tab in
                Button {
                    Haptic.selection()
                    viewModel.selectTab(tab)
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.label)
                            .font(.ion(13, weight: viewModel.selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(viewModel.selectedTab == tab ? Color.brandPrimary : .secondary)
                        Capsule()
                            .fill(viewModel.selectedTab == tab ? Color.brandPrimary : .clear)
                            .frame(height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var dateFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    Button {
                        Haptic.light()
                        viewModel.selectFilter(filter)
                    } label: {
                        Text(filter.label)
                            .font(.ion(12, weight: viewModel.selectedFilter == filter ? .semibold : .medium))
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : .secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                viewModel.selectedFilter == filter
                                    ? Color.brandPrimary
                                    : Color.clear
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        viewModel.selectedFilter == filter ? Color.clear : Color(.systemGray4),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Notification List

    private var notificationList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.filteredItems.enumerated()), id: \.element.id) { index, item in
                    notificationCard(item)
                        .staggeredFadeIn(index: index)
                        .onTapGesture {
                            viewModel.markAsRead(item.id)
                        }

                    if index < viewModel.filteredItems.count - 1 {
                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }
        }
    }

    private func notificationCard(_ item: NotificationItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            notificationIcon(item)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .top) {
                    Text(item.title)
                        .font(.ion(14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(item.timeAgo)
                        .font(.ion(11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(item.body)
                    .font(.ion(12))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if !item.isRead {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(item.isRead ? Color.clear : Color.brandPrimary.opacity(0.04))
    }

    private func notificationIcon(_ item: NotificationItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.brandPrimary.opacity(0.1))
                .frame(width: 44, height: 44)

            Image(systemName: iconForType(item.iconType))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.brandPrimary)
        }
    }

    private func iconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "transaction": "creditcard.fill"
        case "promotion": "tag.fill"
        case "warning": "exclamationmark.triangle.fill"
        case "system": "gearshape.fill"
        case "info": "info.circle.fill"
        default: "bell.fill"
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                viewModel.selectedTab == .unread
                    ? "Tidak Ada Notifikasi Baru"
                    : "Belum Ada Notifikasi",
                systemImage: "bell.slash"
            )
        } description: {
            Text(
                viewModel.selectedTab == .unread
                    ? "Semua notifikasi sudah dibaca."
                    : "Notifikasi terbaru akan muncul di sini."
            )
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { index in
                shimmerRow
                    .staggeredFadeIn(index: index)
                if index < 5 {
                    Divider().padding(.leading, 72)
                }
            }
        }
        .padding(.top, 8)
    }

    private var shimmerRow: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(height: 14)
                    .frame(maxWidth: 160)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
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
