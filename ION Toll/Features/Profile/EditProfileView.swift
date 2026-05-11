import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @State private var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isNameFocused: Bool
    @FocusState private var isPhoneFocused: Bool

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var showDeleteConfirm = false
    @State private var cameraImage: UIImage?
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastDismissTask: Task<Void, Never>?

    init(sessionManager: SessionManager) {
        self._viewModel = State(wrappedValue: EditProfileViewModel(sessionManager: sessionManager))
    }

    var body: some View {
        Form {
            photoSection

            Section("Informasi Pribadi") {
                TextField("Nama Lengkap", text: $viewModel.name)
                    .font(.ionBody)
                    .focused($isNameFocused)
                    .submitLabel(.next)
                    .onSubmit { isNameFocused = false; isPhoneFocused = true }

                TextField("Email", text: .constant(viewModel.email))
                    .font(.ionBody)
                    .foregroundStyle(.secondary)
                    .disabled(true)

                HStack(spacing: 0) {
                    Text("+62")
                        .font(.ionBody)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 8)

                    TextField("No. HP", text: $viewModel.phone)
                        .font(.ionBody)
                        .focused($isPhoneFocused)
                        .keyboardType(.phonePad)
                        .submitLabel(.done)
                        .onSubmit { Task { await viewModel.save() } }
                }
            }
        }
        .navigationTitle("Edit Profil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Simpan") {
                    Task { await viewModel.save() }
                }
                .font(.ionHeadline)
                .foregroundStyle(Color.brandPrimary)
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
            }
        }
        .loadingOverlay(viewModel.isLoading)
        .alert("Berhasil", isPresented: $viewModel.isSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Profil berhasil diperbarui.")
        }
        .confirmationDialog("Ubah Foto Profil", isPresented: $showPhotoOptions) {
            Button("Pilih dari Galeri") {
                showGallery = true
            }
            Button("Ambil Foto") {
                showCamera = true
            }
            if viewModel.hasExistingPhoto || viewModel.selectedImagePreview != nil {
                Button("Hapus Foto", role: .destructive) {
                    showDeleteConfirm = true
                }
            }
            Button("Batal", role: .cancel) {}
        }
        .alert("Hapus Foto", isPresented: $showDeleteConfirm) {
            Button("Hapus", role: .destructive) {
                viewModel.markDeletePhoto()
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Apakah Anda yakin ingin menghapus foto profil?")
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: Binding(
                get: { cameraImage },
                set: { newImage in
                    cameraImage = newImage
                    if let newImage {
                        viewModel.setSelectedImage(newImage)
                    }
                }
            ))
        }
        .photosPicker(isPresented: $showGallery, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.setSelectedImage(uiImage)
                }
                selectedPhoto = nil
            }
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            toastDismissTask?.cancel()
            if let newValue {
                toastMessage = newValue
                withAnimation { showToast = true }
                toastDismissTask = Task {
                    try? await Task.sleep(for: .seconds(2.5))
                    guard !Task.isCancelled else { return }
                    withAnimation { showToast = false }
                    viewModel.errorMessage = nil
                }
            } else {
                withAnimation { showToast = false }
            }
        }
        .onAppear {
            viewModel.resetState()
            selectedPhoto = nil
            cameraImage = nil
        }
        .ionToast(isPresented: $showToast, message: toastMessage, style: .error)
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        Section {
            HStack {
                Spacer()

                Button {
                    showPhotoOptions = true
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        if let preview = viewModel.selectedImagePreview {
                            Image(uiImage: preview)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        } else if !viewModel.shouldDeletePhoto,
                                  let pictureUrl = viewModel.sessionManager.currentUser?.profilePicture,
                                  !pictureUrl.isEmpty {
                            AsyncImage(url: URL(string: pictureUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                defaultAvatar
                            }
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                        } else {
                            defaultAvatar
                        }

                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 8)
        }
    }

    private var defaultAvatar: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 90, height: 90)
            .foregroundStyle(Color.brandPrimary.opacity(0.3))
    }
}
