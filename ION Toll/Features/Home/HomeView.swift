import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var showPinSetup = false
    @State private var isTrafficExpanded = false
    @State private var navigateToCctv = false
    @State private var navigateToProfile = false
    @State private var scrollOffset: CGFloat = 0
    let router: AppRouter?

    init(sessionManager: SessionManager, router: AppRouter? = nil) {
        self._viewModel = State(wrappedValue: HomeViewModel(sessionManager: sessionManager))
        self.router = router
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.brandPrimary
                .frame(height: statusBarHeight)
                .opacity(scrollOffset < -150 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: scrollOffset < -150)
                .ignoresSafeArea()
                .zIndex(1)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .global).minY
                        )
                    }
                    .frame(height: 0)

                    headerSection

                    contentSection
                        .background(Color(.systemBackground))
                        .clipShape(.rect(topLeadingRadius: 28, topTrailingRadius: 28))
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                liveTrafficBar
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .navigationDestination(isPresented: $showPinSetup) {
            PinView(
                sessionManager: viewModel.sessionManager,
                router: router ?? AppRouter(sessionManager: viewModel.sessionManager),
                isSkippable: viewModel.isGuest
            )
        }
        .navigationDestination(isPresented: $navigateToCctv) {
            CctvView(sessionManager: viewModel.sessionManager)
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView(
                sessionManager: viewModel.sessionManager,
                router: router ?? AppRouter(sessionManager: viewModel.sessionManager)
            )
        }
        .onAppear {
            if let router, router.shouldAutoShowPinSetup {
                router.shouldAutoShowPinSetup = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showPinSetup = true
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .top) {
            Image("Banner")
                .resizable()
                .scaledToFill()
                .frame(height: 360)
                .clipped()

            LinearGradient(
                colors: [Color.brandPrimary.opacity(0.85), Color.brandPrimary.opacity(0.01)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 165)

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 60)
                    .padding(.horizontal, 20)

                Spacer()

                walletCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .staggeredFadeIn(index: 0)
            }
        }
        .frame(height: 360)
    }

    private var topBar: some View {
        HStack(spacing: 16) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                    Text(viewModel.locationString)
                        .font(.ionCaption)
                }
                .foregroundStyle(.white.opacity(0.85))

                Text(viewModel.greeting.replacingOccurrences(of: "Selamat ", with: "") + ", \(viewModel.currentUser?.name.split(separator: " ").first.map { String($0) } ?? "Guest")!")
                    .font(.ionHeadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 8) {
                Button {} label: {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }

                Button {
                    Haptic.light()
                    navigateToProfile = true
                } label: {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
    }

    private var walletCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "wallet.fill")
                .font(.title3)
                .foregroundStyle(Color.brandPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.formattedBalance)
                    .font(.ionHeadline)
                Text("0 Poin")
                    .font(.ionCaption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 6) {
                Button {} label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.brandPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.brandPrimary.opacity(0.12))
                        .clipShape(Circle())
                }
                Text("Bayar")
                    .font(.system(size: 10, weight: .medium))
            }

            VStack(spacing: 6) {
                Button {} label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.brandPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.brandPrimary.opacity(0.12))
                        .clipShape(Circle())
                }
                Text("Top Up")
                    .font(.system(size: 10, weight: .medium))
            }
        }
        .padding(16)
        .background(Color.white, in: .rect(cornerRadius: 16))
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(spacing: 28) {
            serviceGrid
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .staggeredFadeIn(index: 0)

            helpSection
                .padding(.horizontal, 20)
                .staggeredFadeIn(index: 1)

            journeyHubSection
                .staggeredFadeIn(index: 2)

            newsSection
                .staggeredFadeIn(index: 3)

            Spacer(minLength: 100)
        }
    }

    // MARK: - Service Grid

    private let services: [(icon: String, title: String)] = [
        ("ic_cctv", "CCTV"),
        ("ic_expand_less", "Derek"),
        ("ic_rest_area", "Rest Area"),
        ("ic_toll", "Tarif Tol"),
        ("ic_receipt", "Resi Digital"),
        ("ic_more_horiz", "Lainnya"),
    ]

    private var serviceGrid: some View {
        VStack(spacing: 12) {
            let rows = [Array(services.prefix(3)), Array(services.suffix(3))]
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 12) {
                    ForEach(Array(row.enumerated()), id: \.element.title) { itemIndex, service in
                        serviceItem(
                            icon: service.icon,
                            title: service.title,
                            index: rowIndex * 3 + itemIndex,
                            action: {
                                handleServiceTap(service.title)
                            }
                        )
                    }
                }
            }
        }
    }

    private func handleServiceTap(_ title: String) {
        Haptic.light()
        switch title {
        case "CCTV":
            navigateToCctv = true
        default:
            break
        }
    }

    private func serviceItem(icon: String, title: String, index: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.brandPrimary.opacity(0.15), Color(.systemBackground)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 64)
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)

                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundStyle(Color.brandPrimary)
                }

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressScaleButtonStyle(scale: 0.93))
        .staggeredFadeIn(index: index)
    }

    // MARK: - Help Section

    private var helpSection: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.brandPrimary)
                Text("Butuh Bantuan?")
                    .font(.ionSubheadline.bold())
            }

            Spacer()

            Button {} label: {
                Text("HUBUNGI KAMI")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.brandPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.brandPrimary, lineWidth: 1))
            }
        }
        .padding(16)
        .background(Color.brandPrimary.opacity(0.08), in: .rect(cornerRadius: 16))
    }

    // MARK: - Journey Hub

    private var journeyHubSection: some View {
        VStack(spacing: 12) {
            sectionHeader(title: "Journey Hub", action: "Lihat semua")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    postinganBaruCard
                        .staggeredFadeIn(index: 0, baseDelay: 0.08)
                    ForEach(0..<3, id: \.self) { index in
                        journeyCard
                            .staggeredFadeIn(index: index + 1, baseDelay: 0.08)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var postinganBaruCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text("Postingan Baru")
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
        }
        .frame(width: 144, height: 256)
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private var journeyCard: some View {
        Image("Banner")
            .resizable()
            .scaledToFill()
            .frame(width: 144, height: 256)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - News

    private var newsSection: some View {
        VStack(spacing: 12) {
            sectionHeader(title: "ION News", action: "Lihat semua")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    newsCard(title: "Jakarta - Bandung", subtitle: "Perjalanan lancar via Tol Cipularang", tag: "Baru")
                        .staggeredFadeIn(index: 0, baseDelay: 0.08)
                    newsCard(title: "Bandung - Semarang", subtitle: "Melewati Tol Trans Jawa", tag: "Populer")
                        .staggeredFadeIn(index: 1, baseDelay: 0.08)
                    newsCard(title: "Surabaya - Malang", subtitle: "Via Tol Waru - Krian", tag: "Baru")
                        .staggeredFadeIn(index: 2, baseDelay: 0.08)
                    newsCard(title: "Jakarta - Cirebon", subtitle: "Tol Tangerang - Merak", tag: "Promo")
                        .staggeredFadeIn(index: 3, baseDelay: 0.08)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func newsCard(title: String, subtitle: String, tag: String) -> some View {
        ZStack(alignment: .bottom) {
            Image("Banner")
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 187)
                .clipped()

            LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                .frame(height: 80)
                .frame(maxHeight: .infinity, alignment: .bottom)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ionSubheadline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.ionCaption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(tag)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.brandPrimary.opacity(0.9), in: .rect(cornerRadius: 6))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(8)
        }
        .frame(width: 250, height: 187)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, action: String) -> some View {
        HStack {
            Text(title)
                .font(.ionHeadline.bold())
            Spacer()
            Button {} label: {
                Text(action)
                    .font(.ionCaption.bold())
                    .foregroundStyle(Color.brandPrimary)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Live Traffic Bar

    private var liveTrafficBar: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    isTrafficExpanded.toggle()
                }
                Haptic.light()
            } label: {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                        Text("Live Traffic")
                            .font(.ionSubheadline.bold())
                    }
                    .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(isTrafficExpanded ? 0 : 180))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .padding(.bottom, 16)
            }

            if isTrafficExpanded {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.4)
            }
        }
        .background(Color.brandPrimary)
        .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
    }

    // MARK: - Status Bar

    private var statusBarHeight: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets.top ?? 59
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
