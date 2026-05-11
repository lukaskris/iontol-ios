import SwiftUI

struct ChangePasswordView: View {
    @State private var viewModel: ChangePasswordViewModel
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isOldPasswordFocused: Bool
    @FocusState private var isNewPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool

    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastDismissTask: Task<Void, Never>?

    init(sessionManager: SessionManager) {
        self._viewModel = State(wrappedValue: ChangePasswordViewModel(sessionManager: sessionManager))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: IONDesign.Spacing.xl) {
                    header

                    if viewModel.step == .verifyOld {
                        verifyOldSection
                    } else {
                        setNewSection
                    }
                }
                .padding(.horizontal, IONDesign.Spacing.xl)
                .padding(.top, IONDesign.Spacing.sm)
            }

            Spacer()

            IONPrimaryButton(
                viewModel.step == .verifyOld ? "Lanjut" : "Lanjut",
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.step == .verifyOld ? !viewModel.isVerifyValid : !viewModel.isNewPasswordValid
            ) {
                if viewModel.step == .verifyOld {
                    Task { await viewModel.verifyOldPassword() }
                } else {
                    Task { await viewModel.changePassword() }
                }
            }
            .padding(.horizontal, IONDesign.Spacing.xl)
            .padding(.bottom, IONDesign.Spacing.lg)
        }
        .navigationTitle("Ubah Password")
        .navigationBarTitleDisplayMode(.inline)
        .loadingOverlay(viewModel.isLoading)
        .alert("Berhasil", isPresented: $viewModel.isSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Password berhasil diubah.")
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
        .ionToast(isPresented: $showToast, message: toastMessage, style: .error)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: IONDesign.Spacing.sm) {
            Text(viewModel.step == .verifyOld ? "Masukan password saat ini" : "Buat Password Login")
                .font(.ionTitle3)
                .foregroundStyle(Color.brandPrimary)

            if viewModel.step == .setNew {
                Text("Buat password baru sesuai petunjuk!")
                    .font(.ionCallout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Step 1: Verify Old Password

    private var verifyOldSection: some View {
        VStack(spacing: IONDesign.Spacing.lg) {
            IONTextField(
                title: "Password",
                placeholder: "Password",
                text: $viewModel.oldPassword,
                isRequired: true,
                autocapitalization: .never,
                isSecure: true,
                submitLabel: .go,
                onSubmit: { Task { await viewModel.verifyOldPassword() } },
                isFocused: $isOldPasswordFocused
            )
        }
    }

    // MARK: - Step 2: Set New Password

    private var setNewSection: some View {
        VStack(spacing: IONDesign.Spacing.lg) {
            IONTextField(
                title: "Buat Password",
                placeholder: "Buat Password",
                text: $viewModel.newPassword,
                isRequired: true,
                autocapitalization: .never,
                isSecure: true,
                submitLabel: .next,
                onSubmit: { isNewPasswordFocused = false; isConfirmPasswordFocused = true },
                isFocused: $isNewPasswordFocused
            )

            IONTextField(
                title: "Ulangi Password",
                placeholder: "Ulangi Password",
                text: $viewModel.confirmPassword,
                isRequired: true,
                autocapitalization: .never,
                isSecure: true,
                submitLabel: .go,
                onSubmit: { Task { await viewModel.changePassword() } },
                isFocused: $isConfirmPasswordFocused
            )
        }
    }
}
