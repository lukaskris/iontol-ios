import SwiftUI
import MapKit

struct RestAreaDetailView: View {
    let restAreaId: String
    let restAreaName: String
    let restAreaDirection: String
    let restAreaDistance: String
    let restAreaImageUrl: String
    let restAreaLatitude: Double
    let restAreaLongitude: Double

    @State private var viewModel = RestAreaDetailViewModel()
    @State private var showCategorySheet = false
    @State private var carouselPage = 0
    @State private var carouselTimer: Timer?

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else {
                detailContent
            }
        }
        .navigationTitle(restAreaName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load(id: restAreaId, distance: restAreaDistance)
        }
        .onDisappear { carouselTimer?.invalidate() }
        .sheet(isPresented: $showCategorySheet) {
            categorySheet
        }
    }

    // MARK: - Detail Content

    private var detailContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                imageCarousel

                titleSection
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)

                tabBar

                tabContent
                    .padding(.bottom, 80)
            }
        }
    }

    // MARK: - Image Carousel

    private var imageCarousel: some View {
        Group {
            if viewModel.images.isEmpty {
                ZStack {
                    Color(.systemGray6)
                        .frame(height: 200)
                    Image(systemName: "location.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                }
            } else if viewModel.images.count == 1 {
                AsyncImage(url: URL(string: viewModel.images[0])) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Color(.systemGray6)
                    }
                }
                .frame(height: 200)
                .clipped()
            } else {
                TabView(selection: $carouselPage) {
                    ForEach(Array(viewModel.images.enumerated()), id: \.offset) { index, url in
                        AsyncImage(url: URL(string: url)) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Color(.systemGray6)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 200)
                .onAppear { startAutoScroll() }
                .overlay(alignment: .bottom) {
                    HStack(spacing: 6) {
                        ForEach(0..<viewModel.images.count, id: \.self) { index in
                            Capsule()
                                .fill(index == carouselPage ? Color.brandPrimary : Color.secondary.opacity(0.4))
                                .frame(width: index == carouselPage ? 18 : 5, height: 5)
                                .animation(.spring(duration: 0.3), value: carouselPage)
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }

    private func startAutoScroll() {
        carouselTimer?.invalidate()
        carouselTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                carouselPage = (carouselPage + 1) % viewModel.images.count
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(viewModel.restArea?.name ?? restAreaName)
                        .font(.ion(16, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text("(\(viewModel.restArea?.distance ?? restAreaDistance))")
                        .font(.ion(12))
                        .foregroundStyle(.secondary)
                }
                Text("Ke Arah \(viewModel.restArea?.direction ?? restAreaDirection)")
                    .font(.ion(12))
                    .foregroundStyle(.secondary)
            }
            Spacer()

            Button {
                openMaps(latitude: viewModel.restArea?.latitude ?? restAreaLatitude,
                         longitude: viewModel.restArea?.longitude ?? restAreaLongitude,
                         name: viewModel.restArea?.name ?? restAreaName)
            } label: {
                Image(systemName: "map.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.brandPrimary, in: Circle())
            }
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            viewModel.selectedTab = tab
                        }
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
            Divider()
        }
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .tenant:
            tenantTab
        case .facility:
            facilityTab
        case .parking:
            parkingTab
        }
    }

    // MARK: Tenant Tab

    private var tenantTab: some View {
        LazyVStack(spacing: 0) {
            HStack {
                categoryFilterChip
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            if viewModel.filteredTenants.isEmpty {
                ContentUnavailableView {
                    Label("Tenant Tidak Ditemukan", systemImage: "storefront")
                } description: {
                    Text(viewModel.tenants.isEmpty ? "Belum ada tenant di rest area ini." : "Tidak ada tenant untuk kategori ini.")
                }
                .padding(.top, 40)
            } else {
                ForEach(viewModel.filteredTenants) { tenant in
                    expandableCard(
                        isExpanded: tenant.isExpanded,
                        icon: { tenantLogo(tenant) },
                        title: tenant.name,
                        onToggle: { viewModel.toggleTenant(tenant.id) }
                    ) {
                        tenantExpandedContent(tenant)
                    }
                }
            }
        }
    }

    private var categoryFilterChip: some View {
        Button { showCategorySheet = true } label: {
            HStack(spacing: 4) {
                Text(selectedCategoryName)
                    .font(.ion(13))
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private func tenantLogo(_ tenant: TenantItem) -> some View {
        Group {
            if let url = URL(string: tenant.logoUrl), !tenant.logoUrl.isEmpty {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Image(systemName: "storefront")
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
            } else {
                Image(systemName: "storefront")
                    .foregroundStyle(Color.brandPrimary)
            }
        }
        .frame(width: 20, height: 20)
    }

    private func tenantExpandedContent(_ tenant: TenantItem) -> some View {
        VStack(spacing: 10) {
            infoRow(label: "Jam Operasional", value: tenant.operationalHours.isEmpty ? "-" : tenant.operationalHours, valueColor: Color.brandPrimary)

            if !tenant.imageUrls.isEmpty {
                HStack(spacing: 8) {
                    ForEach(tenant.imageUrls, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Color(.systemGray6)
                            }
                        }
                        .frame(height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            routeButton(latitude: tenant.latitude, longitude: tenant.longitude, name: tenant.name)
        }
    }

    // MARK: Facility Tab

    private var facilityTab: some View {
        LazyVStack(spacing: 0) {
            if viewModel.facilities.isEmpty {
                ContentUnavailableView {
                    Label("Fasilitas Tidak Tersedia", systemImage: "building.2")
                } description: {
                    Text("Belum ada fasilitas di rest area ini.")
                }
                .padding(.top, 40)
            } else {
                ForEach(viewModel.facilities) { facility in
                    expandableCard(
                        isExpanded: facility.isExpanded,
                        icon: {
                            if let url = URL(string: facility.imageUrl), !facility.imageUrl.isEmpty {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Image(systemName: "location.fill")
                                            .foregroundStyle(Color.brandPrimary)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(Color.brandPrimary)
                            }
                        },
                        title: facility.name,
                        onToggle: { viewModel.toggleFacility(facility.id) }
                    ) {
                        routeButton(latitude: facility.latitude, longitude: facility.longitude, name: facility.name)
                    }
                }
            }
        }
        .padding(.top, 16)
    }

    // MARK: Parking Tab

    private var parkingTab: some View {
        LazyVStack(spacing: 0) {
            if viewModel.parkingAreas.isEmpty {
                ContentUnavailableView {
                    Label("Area Parkir Tidak Tersedia", systemImage: "localParking")
                } description: {
                    Text("Belum ada area parkir di rest area ini.")
                }
                .padding(.top, 40)
            } else {
                ForEach(viewModel.parkingAreas) { parking in
                    expandableCard(
                        isExpanded: parking.isExpanded,
                        icon: {
                            Image(systemName: "localParking")
                                .foregroundStyle(Color.brandPrimary)
                        },
                        title: parking.name,
                        onToggle: { viewModel.toggleParking(parking.id) }
                    ) {
                        parkingExpandedContent(parking)
                    }
                }
            }
        }
        .padding(.top, 16)
    }

    private func parkingExpandedContent(_ parking: ParkingAreaItem) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Status")
                    .font(.ion(12))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(parking.status)
                    .font(.ion(11, weight: .semibold))
                    .foregroundStyle(parking.isAvailable ? .green : .red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(parking.isAvailable ? Color.green.opacity(0.15) : Color.red.opacity(0.15), in: Capsule())
            }

            infoRow(label: "Total Slot", value: "\(parking.totalSlot)")
            infoRow(label: "Slot Kosong", value: "\(parking.available)", valueColor: .green)
            infoRow(label: "Slot Terisi", value: "\(parking.unavailable)", valueColor: .red)

            routeButton(latitude: viewModel.restArea?.latitude ?? restAreaLatitude,
                        longitude: viewModel.restArea?.longitude ?? restAreaLongitude,
                        name: parking.name, label: "Akses CCTV", icon: "video.fill")
        }
    }

    // MARK: - Category Sheet

    private var categorySheet: some View {
        NavigationStack {
            List {
                categoryRow(title: "Semua Kategori", isSelected: viewModel.selectedCategoryId == nil) {
                    viewModel.selectCategory(nil)
                    showCategorySheet = false
                }

                ForEach(viewModel.categories) { cat in
                    categoryRow(title: cat.name, isSelected: viewModel.selectedCategoryId == cat.id) {
                        viewModel.selectCategory(cat.id)
                        showCategorySheet = false
                    }
                }
            }
            .navigationTitle("Pilih Kategori")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Selesai") { showCategorySheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func categoryRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.ion(14, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.brandPrimary : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.brandPrimary)
                }
            }
        }
    }

    // MARK: - Shared Components

    private func expandableCard<Icon: View, Content: View>(
        isExpanded: Bool,
        @ViewBuilder icon: () -> Icon,
        title: String,
        onToggle: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    icon()
                }
                Text(title)
                    .font(.ion(14, weight: .semibold))
                    .foregroundStyle(Color.brandPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if isExpanded {
                VStack(spacing: 0) {
                    content()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 14)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                onToggle()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }

    private func infoRow(label: String, value: String, valueColor: Color = .primary) -> some View {
        HStack {
            Text(label)
                .font(.ion(12))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.ion(13, weight: .semibold))
                .foregroundStyle(valueColor)
        }
    }

    private func routeButton(latitude: Double, longitude: Double, name: String, label: String = "Cari Rute", icon: String = "location.fill") -> some View {
        Button {
            openMaps(latitude: latitude, longitude: longitude, name: name)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(.ion(13, weight: .bold))
            }
            .foregroundStyle(Color.brandPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }

    // MARK: - Helpers

    private var selectedCategoryName: String {
        guard let id = viewModel.selectedCategoryId else { return "Semua Kategori" }
        return viewModel.categories.first(where: { $0.id == id })?.name ?? "Semua Kategori"
    }

    private func openMaps(latitude: Double, longitude: Double, name: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Gagal Memuat", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Coba Lagi") {
                viewModel.load(id: restAreaId, distance: restAreaDistance)
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color.brandPrimary)
        }
    }
}
