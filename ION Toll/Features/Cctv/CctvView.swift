import SwiftUI
import MapKit

struct CctvView: View {
    @State private var viewModel: CctvViewModel
    @State private var showMapMode = false
    @State private var selectedCctvForNavigation: CctvItem?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var appearedPins: Set<String> = []

    init(sessionManager: SessionManager) {
        self._viewModel = State(wrappedValue: CctvViewModel(sessionManager: sessionManager))
    }

    var body: some View {
        Group {
            if showMapMode {
                mapModeView
            } else {
                listModeView
            }
        }
        .navigationTitle("CCTV")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(showMapMode)
        .toolbar {
            if showMapMode {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Haptic.light()
                        withAnimation(.spring(duration: 0.35)) {
                            showMapMode = false
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
        .onDisappear {
            viewModel.searchQuery = ""
        }
        .task {
            await viewModel.loadCctvList()
        }
        .navigationDestination(item: $selectedCctvForNavigation) { item in
            SegmentView(
                cctvId: item.id,
                sectionName: item.section,
                sessionManager: viewModel.sessionManager
            )
        }
    }

    // MARK: - List Mode

    private var listModeView: some View {
        VStack(spacing: 0) {
            searchBar

            if viewModel.isLoading {
                loadingShimmer
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else {
                cctvListContent
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("Cari section CCTV...", text: $viewModel.searchQuery)
                .font(.ionSubheadline)

            if !viewModel.searchQuery.isEmpty {
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        viewModel.searchQuery = ""
                    }
                    Haptic.light()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.systemGray6), in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator).opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var cctvListContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 6) {
                currentLocationHeader

                if viewModel.filteredList.isEmpty && !viewModel.searchQuery.isEmpty {
                    emptySearchResult
                } else {
                    ForEach(Array(viewModel.filteredList.enumerated()), id: \.element.id) { index, item in
                        cctvListItem(item: item, index: index)
                    }
                }
            }
        }
    }

    private var currentLocationHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "location.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.brandPrimary)
            Text("Lokasi saat ini")
                .font(.ionSubheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func cctvListItem(item: CctvItem, index: Int) -> some View {
        HStack(spacing: 14) {
            Image("ic_toll")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(Color.brandPrimary)

            Text(item.section)
                .font(.ionSubheadline.bold())
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                Haptic.light()
                if let lat = item.latitude, let lon = item.longitude, lat != 0, lon != 0 {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: lat - 0.005, longitude: lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.008)
                    ))
                }
                withAnimation(.spring(duration: 0.35)) {
                    showMapMode = true
                }
                Task {
                    await viewModel.loadCctvDetail(for: item)
                }
            } label: {
                Image(systemName: "map")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            Haptic.light()
            withAnimation(.spring(duration: 0.3)) {
                selectedCctvForNavigation = item
            }
        }
        .padding(.horizontal, 20)
        .staggeredFadeIn(index: index)
    }

    private var emptySearchResult: some View {
        VStack(spacing: 12) {
            Image(systemName: "video.slash")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Tidak ada CCTV yang ditemukan")
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Map Mode

    private var mapModeView: some View {
        ZStack {
            Map(position: $cameraPosition) {
                // Section markers
                ForEach(Array(viewModel.cctvItems.enumerated()), id: \.element.id) { index, item in
                    if let coordinate = item.coordinate {
                        Annotation(item.section, coordinate: coordinate) {
                            sectionPin(item: item, index: index)
                        }
                    }
                }

                // Detail CCTV markers
                ForEach(viewModel.cctvDetailList) { detail in
                    if detail.latitude != 0 && detail.longitude != 0 {
                        Annotation(detail.cctv, coordinate: CLLocationCoordinate2D(latitude: detail.latitude, longitude: detail.longitude)) {
                            detailPin(detail: detail)
                        }
                    }
                }

                // Polyline connecting detail points
                if viewModel.cctvDetailList.count >= 2 {
                    MapPolyline(coordinates: viewModel.cctvDetailList.compactMap { detail in
                        detail.latitude != 0 && detail.longitude != 0
                            ? CLLocationCoordinate2D(latitude: detail.latitude, longitude: detail.longitude)
                            : nil
                    })
                    .stroke(Color.brandPrimary.opacity(0.6), lineWidth: 3)
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea(edges: .bottom)

            // Loading overlay
            if viewModel.isLoadingDetail {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.2)
                        Text("Memuat data CCTV...")
                            .font(.ionSubheadline)
                            .foregroundStyle(.white)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                }
                .transition(.opacity)
            }

            // Section info card (when section tapped, no detail yet)
            if viewModel.selectedCctvItem != nil && viewModel.cctvDetailList.isEmpty && !viewModel.isLoadingDetail {
                VStack {
                    Spacer()
                    if let selected = viewModel.selectedCctvItem {
                        sectionInfoCard(item: selected)
                    }
                }
            }

            // Detail horizontal scroll card
            if let selectedDetail = viewModel.selectedDetailCctv, !viewModel.cctvDetailList.isEmpty {
                VStack {
                    Spacer()
                    detailScrollCard(selectedDetail: selectedDetail)
                }
            }
        }
        .task(id: viewModel.cctvDetailList.count) {
            print("[MAP DEBUG] task triggered, count=\(viewModel.cctvDetailList.count)")
            guard !viewModel.cctvDetailList.isEmpty else { return }
            try? await Task.sleep(for: .milliseconds(300))
            print("[MAP DEBUG] calling zoomToFitDetailPoints after 300ms delay")
            zoomToFitDetailPoints()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            print("[MAP DEBUG] camera final: center.lat=\(context.region.center.latitude), center.lon=\(context.region.center.longitude), span.lat=\(context.region.span.latitudeDelta), span.lon=\(context.region.span.longitudeDelta)")
        }
    }

    private func zoomToFitDetailPoints() {
        let validPoints = viewModel.cctvDetailList.filter { $0.latitude != 0 && $0.longitude != 0 }
        guard !validPoints.isEmpty else { return }

        if validPoints.count == 1, let point = validPoints.first {
            let shiftedLat = point.latitude - 0.005
            print("""
            [MAP DEBUG] Single point:
              Original: lat=\(point.latitude), lon=\(point.longitude)
              Shifted:  lat=\(shiftedLat), lon=\(point.longitude)
              Span: lat=0.015, lon=0.008
            """)
            withAnimation(.easeInOut(duration: 0.5)) {
                cameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: shiftedLat, longitude: point.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.008)
                ))
            }
            return
        }

        let latitudes = validPoints.map(\.latitude)
        let longitudes = validPoints.map(\.longitude)

        let minLat = latitudes.min()!
        let maxLat = latitudes.max()!
        let minLon = longitudes.min()!
        let maxLon = longitudes.max()!

        let rawCenterLat = (minLat + maxLat) / 2
        let rawCenterLon = (minLon + maxLon) / 2
        let rawSpanLat = (maxLat - minLat) * 1.3 + 0.005
        let rawSpanLon = (maxLon - minLon) * 1.3 + 0.005
        let maxSpan = max(rawSpanLat, rawSpanLon)
        let finalSpanLat = maxSpan * 1.9
        let finalSpanLon = maxSpan
        let centerLat = rawCenterLat - finalSpanLat * 0.12
        let centerLon = rawCenterLon

        print("""
        [MAP DEBUG] Multiple points (\(validPoints.count)):
          Min: lat=\(minLat), lon=\(minLon)
          Max: lat=\(maxLat), lon=\(maxLon)
          Raw center: lat=\(rawCenterLat), lon=\(rawCenterLon)
          Final span: lat=\(finalSpanLat), lon=\(finalSpanLon)
          Final center: lat=\(centerLat), lon=\(centerLon)
        """)

        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(latitudeDelta: finalSpanLat, longitudeDelta: finalSpanLon)
            ))
        }
    }

    private func sectionPin(item: CctvItem, index: Int) -> some View {
        let hasAppeared = appearedPins.contains(item.id)
        let isSelected = viewModel.selectedCctvItem?.id == item.id

        return Button {
            Haptic.medium()
            if viewModel.selectedCctvItem?.id == item.id {
                viewModel.clearSelection()
            } else {
                Task {
                    await viewModel.loadCctvDetail(for: item)
                }
            }
        } label: {
            Image(systemName: "video.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                .background(
                    LinearGradient(
                        colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color.brandPrimary.opacity(0.4), radius: isSelected ? 6 : 4, y: 2)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: isSelected ? 3 : 2)
                        .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                )
                .animation(.spring(duration: 0.3, bounce: 0.3), value: isSelected)
        }
        .scaleEffect(hasAppeared ? 1 : 0)
        .opacity(hasAppeared ? 1 : 0)
        .onAppear {
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(duration: 0.4, bounce: 0.35)) {
                    appearedPins.insert(item.id)
                    return ()
                }
            }
        }
    }

    private func detailPin(detail: CctvDetailItem) -> some View {
        let isSelected = viewModel.selectedDetailCctv?.id == detail.id

        return Button {
            Haptic.light()
            withAnimation(.spring(duration: 0.3, bounce: 0.25)) {
                viewModel.selectedDetailCctv = detail
            }
        } label: {
            Image(systemName: "video.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: isSelected ? 32 : 26, height: isSelected ? 32 : 26)
                .background(
                    LinearGradient(
                        colors: [Color.brandPrimary.opacity(0.9), Color.brandPrimary.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                        .frame(width: isSelected ? 32 : 26, height: isSelected ? 32 : 26)
                )
                .animation(.spring(duration: 0.25, bounce: 0.2), value: isSelected)
        }
    }

    // MARK: - Section Info Card

    private func sectionInfoCard(item: CctvItem) -> some View {
        HStack(spacing: 12) {
            Image("ic_toll")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(Color.brandPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.section)
                    .font(.ionSubheadline.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if item.distance > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(formatDistance(item.distance))
                            .font(.ionCaption)
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image("ic_cctv")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.brandPrimary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Detail Scroll Card

    private func detailScrollCard(selectedDetail: CctvDetailItem) -> some View {
        VStack(spacing: 0) {
            // Video player area
            ZStack {
                Color.black
                    .frame(height: 220)
                    .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))

                if selectedDetail.hasStream {
                    HLSPlayerView(urlString: selectedDetail.linkStream)
                        .frame(height: 220)
                        .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Stream tidak tersedia")
                            .font(.ionCaption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(height: 220)
                }
            }

            // Info row
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary)
                        .frame(width: 24, height: 24)
                    Image("ic_cctv")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(.white)
                }

                Text(selectedDetail.cctv)
                    .font(.ionSubheadline.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                if let index = viewModel.cctvDetailList.firstIndex(where: { $0.id == selectedDetail.id }) {
                    Text("\(index + 1)/\(viewModel.cctvDetailList.count)")
                        .font(.ionCaption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(.rect(bottomLeadingRadius: 16, bottomTrailingRadius: 16))

            // Horizontal camera picker
            if viewModel.cctvDetailList.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.cctvDetailList) { detail in
                            cameraThumbCard(detail: detail, isSelected: detail.id == selectedDetail.id)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
        }
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func cameraThumbCard(detail: CctvDetailItem, isSelected: Bool) -> some View {
        Button {
            Haptic.light()
            withAnimation(.spring(duration: 0.25, bounce: 0.2)) {
                viewModel.selectedDetailCctv = detail
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "video.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? .white : Color.brandPrimary)

                Text(detail.cctv)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? Color.brandPrimary : Color(.secondarySystemBackground), in: .capsule)
            .overlay(
                Capsule().stroke(isSelected ? Color.clear : Color(.separator).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleButtonStyle(scale: 0.95))
    }

    // MARK: - Loading & Error

    private var loadingShimmer: some View {
        VStack(spacing: 0) {
            currentLocationHeader
            ForEach(0..<8, id: \.self) { index in
                Divider().padding(.leading, 20)
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
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
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
                Task { await viewModel.loadCctvList() }
            }
            .font(.ionSubheadline.bold())
            .foregroundStyle(Color.brandPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    // MARK: - Helpers

    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters)) m"
        } else {
            return String(format: "%.1f km", meters / 1000.0)
        }
    }
}
