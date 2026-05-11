import SwiftUI

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let date: String
    let category: String

    var categoryColor: Color {
        switch category {
        case "Pengumuman": .brandPrimary
        case "Promo": .green
        case "Pembaruan": .orange
        case "Perbaikan": .red
        default: .secondary
        }
    }
}

struct NewsView: View {
    private let sampleNews: [NewsItem] = [
        NewsItem(
            title: "Gerbang Tol Baru di Jalan Tol 5",
            summary: "Mulai bulan depan, gerbang tol baru akan beroperasi di Jalan Tol 5, seksi B. Pembayaran elektronik akan tersedia.",
            date: "11 Apr 2026",
            category: "Pengumuman"
        ),
        NewsItem(
            title: "Diskon Akhir Pekan: 20% Semua Tol",
            summary: "Nikmati diskon 20% untuk semua perjalanan tol akhir pekan ini. Berlaku untuk pembayaran elektronik dan tunai.",
            date: "10 Apr 2026",
            category: "Promo"
        ),
        NewsItem(
            title: "Pembaruan Aplikasi v2.0 Tersedia",
            summary: "Kami menambahkan harga tol real-time, perencanaan rute, dan dukungan Apple Pay. Perbarui sekarang.",
            date: "9 Apr 2026",
            category: "Pembaruan"
        ),
        NewsItem(
            title: "Perbaikan Terjadwal: 15 April",
            summary: "Beberapa gerbang tol di Jalan Tol 1 akan menjalani perbaikan pada 15 April. Perkirakan sedikit keterlambatan antara jam 6 pagi hingga 10 pagi.",
            date: "8 Apr 2026",
            category: "Perbaikan"
        )
    ]

    var body: some View {
        List(sampleNews) { item in
            newsRow(item: item)
                .staggeredFadeIn(index: sampleNews.firstIndex(where: { $0.id == item.id }) ?? 0)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: IONDesign.Spacing.lg, bottom: 6, trailing: IONDesign.Spacing.lg))
        }
        .listStyle(.plain)
        .navigationTitle("Berita")
    }

    private func newsRow(item: NewsItem) -> some View {
        VStack(alignment: .leading, spacing: IONDesign.Spacing.sm) {
            HStack {
                Text(item.category)
                    .font(.ionCaption.bold())
                    .padding(.horizontal, IONDesign.Spacing.sm)
                    .padding(.vertical, IONDesign.Spacing.xs)
                    .background(item.categoryColor.opacity(0.12))
                    .foregroundStyle(item.categoryColor)
                    .clipShape(Capsule())

                Spacer()

                Text(item.date)
                    .font(.ionCaption)
                    .foregroundStyle(.secondary)
            }

            Text(item.title)
                .font(.ionHeadline)

            Text(item.summary)
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(IONDesign.Spacing.md)
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: IONDesign.Radius.md))
    }
}

#Preview {
    NavigationStack {
        NewsView()
    }
}
