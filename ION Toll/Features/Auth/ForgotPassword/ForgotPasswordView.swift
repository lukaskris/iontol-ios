import SwiftUI

struct ForgotPasswordView: View {
    @State private var viewModel = ForgotPasswordViewModel()
    @State private var showToast = false
    @State private var toastMessage = ""
    @FocusState private var isEmailFocused: Bool

    var body: some View {
        VStack(spacing: IONDesign.Spacing.xl) {
            header

            if viewModel.isSuccess {
                successView
            } else {
                form
                submitButton
            }

            Spacer()
        }
        .padding(.horizontal, IONDesign.Spacing.xl)
        .padding(.top, 40)
        .navigationBarTitleDisplayMode(.inline)
        .ionToast(isPresented: $showToast, message: toastMessage, style: .error)
        .onChange(of: viewModel.errorMessage) {
            if let message = viewModel.errorMessage {
                toastMessage = message
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showToast = false
                }
            }
        }
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
        IONTextField(
            title: "Email",
            placeholder: "Email",
            text: $viewModel.email,
            keyboardType: .emailAddress,
            autocapitalization: .never,
            submitLabel: .go,
            onSubmit: { Task { await viewModel.submit() } },
            isFocused: $isEmailFocused
        )
        .staggeredFadeIn(index: 1)
    }

    private var submitButton: some View {
        IONPrimaryButton(
            "Kirim Link Reset",
            isLoading: viewModel.isLoading,
            isDisabled: viewModel.email.isEmpty
        ) {
            Task { await viewModel.submit() }
        }
        .staggeredFadeIn(index: 2)
    }

    private var successView: some View {
        VStack(spacing: IONDesign.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Email Terkirim")
                .font(.ionHeadline)

            Text("Silakan periksa email Anda untuk tautan pengaturan ulang password.")
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
