import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var showLogoutAlert = false
    @State private var showEditProfile = false
    @State private var showChangePassword = false
    @State private var showChangePin = false

    init(sessionManager: SessionManager, router: AppRouter) {
        self._viewModel = State(wrappedValue: ProfileViewModel(sessionManager: sessionManager, router: router))
    }

    var body: some View {
        List {
            profileSection
            accountSection
            preferencesSection
            logoutSection
        }
        .navigationTitle("Profil")
    }

    // MARK: - Sections

    private var profileSection: some View {
        Section {
            HStack(spacing: IONDesign.Spacing.lg) {
                if let pictureUrl = viewModel.currentUser?.profilePicture, !pictureUrl.isEmpty {
                    AsyncImage(url: URL(string: pictureUrl)) { image in
                        image.resizable()
                    } placeholder: {
                        defaultAvatar
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else {
                    defaultAvatar
                }

                VStack(alignment: .leading, spacing: IONDesign.Spacing.xs) {
                    Text(viewModel.currentUser?.name ?? "Pengguna")
                        .font(.ionHeadline)
                    Text(viewModel.currentUser?.email ?? "")
                        .font(.ionSubheadline)
                        .foregroundStyle(.secondary)
                    if let phone = viewModel.currentUser?.phoneNumber, !phone.isEmpty {
                        Text(phone)
                            .font(.ionCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, IONDesign.Spacing.xs)
        }
    }

    private var defaultAvatar: some View {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 50))
            .foregroundStyle(Color.brandPrimary)
            .staggeredFadeIn(index: 0)
    }

    private var accountSection: some View {
        Section("Akun") {
            Button {
                showEditProfile = true
            } label: {
                row(icon: "person.fill", title: "Edit Profil")
            }
            .buttonStyle(.plain)

            Button {
                showChangePassword = true
            } label: {
                row(icon: "lock.fill", title: "Ubah Password")
            }
            .buttonStyle(.plain)

            if viewModel.currentUser?.hasPin == true {
                Button {
                    showChangePin = true
                } label: {
                    row(icon: "lock.shield.fill", title: "Ubah PIN")
                }
            }

            row(icon: "creditcard.fill", title: "Metode Pembayaran")
            row(icon: "bell.fill", title: "Notifikasi")
        }
        .navigationDestination(isPresented: $showEditProfile) {
            EditProfileView(sessionManager: viewModel.sessionManager)
        }
        .navigationDestination(isPresented: $showChangePassword) {
            ChangePasswordView(sessionManager: viewModel.sessionManager)
        }
        .navigationDestination(isPresented: $showChangePin) {
            ChangePinView(sessionManager: viewModel.sessionManager)
        }
    }

    private var preferencesSection: some View {
        Section("Preferensi") {
            row(icon: "globe", title: "Bahasa")
            row(icon: "questionmark.circle.fill", title: "Bantuan & Dukungan")
            row(icon: "info.circle.fill", title: "Tentang ION Toll")
        }
    }

    private var logoutSection: some View {
        Section {
            Button(role: .destructive) {
                showLogoutAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                    Text("Keluar")
                        .font(.ionBody)
                }
            }
            .buttonStyle(.pressScale)
        }
        .alert("Keluar", isPresented: $showLogoutAlert) {
            Button("Batal", role: .cancel) {}
            Button("Keluar", role: .destructive) {
                Task {
                    await viewModel.logout()
                }
            }
        } message: {
            Text("Apakah Anda yakin ingin keluar?")
        }
    }

    // MARK: - Helpers

    private func row(icon: String, title: String) -> some View {
        HStack(spacing: IONDesign.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(Color.brandPrimary)
                .frame(width: 24)
            Text(title)
                .font(.ionBody)
                .foregroundStyle(.primary)
        }
    }
}
