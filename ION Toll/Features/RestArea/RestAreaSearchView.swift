import SwiftUI

struct RestAreaSearchView: View {
    let items: [RestAreaItem]
    let onSelect: (RestAreaItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @FocusState private var isSearchFocused: Bool
    @State private var selectedId: String?

    private var filtered: [RestAreaItem] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        List {
            if !query.isEmpty && filtered.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                ForEach(filtered) { item in
                    Button {
                        selectedId = item.id
                        isSearchFocused = false
                        onSelect(item)
                    } label: {
                        searchRow(item)
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $query, prompt: "Cari Rest Area...")
        .onAppear { isSearchFocused = true }
    }

    private func searchRow(_ item: RestAreaItem) -> some View {
        HStack(spacing: 12) {
            if selectedId == item.id {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary)
                        .frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "location.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.brandPrimary)
                    .frame(width: 22)
            }

            Text(item.name)
                .font(.ion(15, weight: selectedId == item.id ? .semibold : .medium))
                .foregroundStyle(selectedId == item.id ? Color.brandPrimary : .primary)
                .lineLimit(1)

            Spacer()

            Text(item.direction)
                .font(.ionCaption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
        .animation(.spring(duration: 0.3, bounce: 0.3), value: selectedId)
    }
}
