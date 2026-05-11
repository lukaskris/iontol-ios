import SwiftUI

struct PhoneInputView: View {
    @State private var viewModel: PhoneInputViewModel
    @FocusState private var isPhoneFocused: Bool

    init(sessionManager: SessionManager, router: AppRouter) {
        self._viewModel = State(wrappedValue: PhoneInputViewModel(sessionManager: sessionManager, router: router))
    }

    var body: some View {
        VStack(spacing: IONDesign.Spacing.xl) {
            header

            phoneField

            IONErrorBanner(message: viewModel.errorMessage)

            submitButton

            Spacer()
        }
        .padding(.horizontal, IONDesign.Spacing.xl)
        .padding(.top, 40)
        .navigationTitle("Verifikasi Nomor HP")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: IONDesign.Spacing.sm) {
            Image(systemName: "phone.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.brandPrimary)

            Text("Verifikasi Nomor HP")
                .font(.ionTitle2)
                .foregroundStyle(Color.brandPrimary)

            Text("Masukkan nomor HP Anda untuk verifikasi melalui OTP.")
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var phoneField: some View {
        HStack(spacing: IONDesign.Spacing.sm) {
            Text("+62")
                .font(.ionHeadline)
                .foregroundStyle(.primary)
                .padding(.trailing, 4)

            TextField("8123456789", text: $viewModel.phone)
                .focused($isPhoneFocused)
                .keyboardType(.phonePad)
                .font(.ionBody)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.go)
        }
    }

    private var submitButton: some View {
        IONPrimaryButton(
            "Kirim OTP",
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid
        ) {
            Task { await viewModel.submit() }
        }
    }
}
