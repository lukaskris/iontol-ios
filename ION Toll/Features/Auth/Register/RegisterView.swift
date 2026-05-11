import SwiftUI

struct RegisterView: View {
    @State private var viewModel: RegisterViewModel
    @State private var shakeOffset: CGFloat = 0
    @State private var isAgreed = false
    @State private var showToast = false
    @State private var toastMessage = ""

    @FocusState private var isFullNameFocused: Bool
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPhoneFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isConfirmFocused: Bool

    init(viewModel: RegisterViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: IONDesign.Spacing.xl) {
                header
                form
                termsCheckbox
                registerButton
            }
            .padding(.horizontal, IONDesign.Spacing.xl)
            .padding(.top, IONDesign.Spacing.sm)
        }
        .navigationTitle("")
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
            triggerShake()
        }
    }

    // MARK: - Components
    private var header: some View {
        VStack(alignment: .leading, spacing: IONDesign.Spacing.sm) {
            Text("Buat Akun")
                .font(.ionTitle3)
                .foregroundStyle(Color.brandPrimary)
            Text("Akses semua itur dengan membuat akun baru.")
                .font(.ionCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private var form: some View {
        VStack(spacing: 14) {
            IONTextField(
                title: "Nama Lengkap",
                placeholder: "Nama Lengkap",
                text: $viewModel.name,
                isRequired: true,
                submitLabel: .next,
                onSubmit: { isFullNameFocused = false; isEmailFocused = true },
                isFocused: $isFullNameFocused
            )
            .staggeredFadeIn(index: 1)

            IONTextField(
                title: "Email",
                placeholder: "Email",
                text: $viewModel.email,
                isRequired: true,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                submitLabel: .next,
                onSubmit: { isEmailFocused = false; isPhoneFocused = true },
                errorMessage: viewModel.validatedEmailError,
                isFocused: $isEmailFocused
            )
            .staggeredFadeIn(index: 2)

            IONTextField(
                title: "No. HP",
                placeholder: "812xxxxxxx",
                text: $viewModel.phone,
                isRequired: true,
                prefix: "+62",
                keyboardType: .phonePad,
                submitLabel: .next,
                onSubmit: { isPhoneFocused = false; isPasswordFocused = true },
                errorMessage: viewModel.validatedPhoneError,
                isFocused: $isPhoneFocused
            )
            .staggeredFadeIn(index: 3)

            IONTextField(
                title: "Password",
                placeholder: "Password",
                text: $viewModel.password,
                isRequired: true,
                isSecure: true,
                submitLabel: .next,
                onSubmit: { isPasswordFocused = false; isConfirmFocused = true },
                errorMessage: viewModel.validatedPasswordError,
                isFocused: $isPasswordFocused
            )
            .staggeredFadeIn(index: 4)

            IONTextField(
                title: "Konfirmasi Password",
                placeholder: "Konfirmasi Password",
                text: $viewModel.confirmPassword,
                isRequired: true,
                isSecure: true,
                submitLabel: .go,
                onSubmit: { performRegister() },
                errorMessage: viewModel.validatedConfirmPasswordError,
                isFocused: $isConfirmFocused
            )
            .staggeredFadeIn(index: 5)
        }
        .modifier(ShakeEffect(animatableData: shakeOffset))
    }

    private var termsCheckbox: some View {
        HStack(alignment: .top, spacing: IONDesign.Spacing.sm) {
            Button {
                isAgreed.toggle()
            } label: {
                Image(systemName: isAgreed ? "checkmark.square.fill" : "square")
                    .font(.body)
                    .foregroundStyle(isAgreed ? Color.brandPrimary : .secondary)
            }

            (Text("Dengan mendaftarkan akun, Anda menyetujui ")
                .font(.ionCaption)
                .foregroundStyle(.secondary)
            + Text("Ketentuan Pengguna")
                .font(.ionCaption)
                .foregroundStyle(Color.brandPrimary)
                .underline()
            + Text(" & ")
                .font(.ionCaption)
                .foregroundStyle(.secondary)
            + Text("Kebijakan Privasi")
                .font(.ionCaption)
                .foregroundStyle(Color.brandPrimary)
                .underline()
            + Text(" kami.")
                .font(.ionCaption)
                .foregroundStyle(.secondary))
            .onTapGesture {
                showTermsToast()
            }
        }
        .staggeredFadeIn(index: 6)
    }

    private var registerButton: some View {
        IONPrimaryButton(
            "Buat Akun",
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid || !isAgreed
        ) {
            performRegister()
        }
        .staggeredFadeIn(index: 7)
    }

    // MARK: - Actions

    private func performRegister() {
        guard viewModel.isFormValid else { return }
        isFullNameFocused = false
        isEmailFocused = false
        isPhoneFocused = false
        isPasswordFocused = false
        isConfirmFocused = false
        Task {
            await viewModel.register()
        }
    }

    private func triggerShake() {
        guard viewModel.errorMessage != nil else { return }
        withAnimation(.spring(duration: 0.4, bounce: 0.4)) {
            shakeOffset = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            shakeOffset = 0
        }
    }

    private func showTermsToast() {
        toastMessage = "Halaman ketentuan pengguna akan segera tersedia"
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showToast = false
        }
    }
}
