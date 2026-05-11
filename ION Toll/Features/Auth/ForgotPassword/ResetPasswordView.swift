import SwiftUI

struct ResetPasswordView: View {
    @State private var viewModel: ResetPasswordViewModel
    @FocusState private var isNewPasswordFocused: Bool

    init(token: String) {
        self._viewModel = State(wrappedValue: ResetPasswordViewModel(token: token))
    }

    var body: some View {
        VStack(spacing: IONDesign.Spacing.xl) {
            header

            if viewModel.isSuccess {
                successView
            } else {
                form
                IONErrorBanner(message: viewModel.errorMessage)
                submitButton
            }

            Spacer()
        }
        .padding(.horizontal, IONDesign.Spacing.xl)
        .padding(.top, 40)
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: IONDesign.Spacing.sm) {
            Text("Lupa Password")
                .font(.ionTitle3)
                .foregroundStyle(Color.brandPrimary)
            Text("Masukkan email terdaftar untuk mendapatkan link reset password")
                .font(.ionCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var form: some View {
        VStack(spacing: IONDesign.Spacing.lg) {
            IONTextField(
                title: "Password Baru",
                placeholder: "Password Baru",
                text: $viewModel.newPassword,
                isSecure: true,
                submitLabel: .next,
                onSubmit: { isNewPasswordFocused = false },
                isFocused: $isNewPasswordFocused
            )

            IONTextField(
                title: "Konfirmasi Password Baru",
                placeholder: "Konfirmasi Password Baru",
                text: $viewModel.confirmPassword,
                isSecure: true,
                submitLabel: .go,
                onSubmit: { Task { await viewModel.submit() } },
                isFocused: $isNewPasswordFocused
            )
        }
    }

    private var submitButton: some View {
        IONPrimaryButton(
            "Simpan Password",
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid
        ) {
            Task { await viewModel.submit() }
        }
    }

    private var successView: some View {
        VStack(spacing: IONDesign.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Password Berhasil Diubah")
                .font(.ionHeadline)

            Text("Silakan masuk dengan password baru Anda.")
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
        }
    }
}
