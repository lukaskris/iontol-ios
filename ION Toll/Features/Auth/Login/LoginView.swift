import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @State private var showForgotPassword = false
    @State private var showToast = false
    @State private var toastMessage = ""

    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    init(viewModel: LoginViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: IONDesign.Spacing.xl) {
                header
                form
                forgotPasswordLink
                loginButton

                IONOrDivider()
                    .staggeredFadeIn(index: 5)

                GoogleSignInButton(isLoading: viewModel.isGoogleLoading) {
                    Task { await viewModel.signInWithGoogle() }
                }
                .staggeredFadeIn(index: 6)

                AppleSignInButton(isLoading: viewModel.isAppleLoading) {
                    Task { await viewModel.signInWithApple() }
                }
                .staggeredFadeIn(index: 7)
            }
            .padding(.horizontal, IONDesign.Spacing.xl)
            .padding(.top, IONDesign.Spacing.sm)
        }
        .navigationDestination(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .ionToast(isPresented: $showToast, message: toastMessage, style: .error)
        .onAppear {
            viewModel.onError = { (message: String) in
                toastMessage = message
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showToast = false
                }
            }
            viewModel.setupRoutingErrorHandler()
        }
    }

    // MARK: - Components

    private var header: some View {
        VStack(alignment: .leading, spacing: IONDesign.Spacing.sm) {
            Text("Masuk Akun")
                .font(.ionTitle3)
                .foregroundStyle(Color.brandPrimary)
            Text("Gunakan email dan password yang terdaftar untuk melanjutkan")
                .font(.ionCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .staggeredFadeIn(index: 0)
    }

    private var form: some View {
        VStack(spacing: IONDesign.Spacing.lg) {
            IONTextField(
                title: "Email",
                placeholder: "Email",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                submitLabel: .next,
                onSubmit: { isPasswordFocused = true; isEmailFocused = false },
                isFocused: $isEmailFocused
            )
            .staggeredFadeIn(index: 1)

            IONTextField(
                title: "Password",
                placeholder: "Password",
                text: $viewModel.password,
                isSecure: true,
                submitLabel: .go,
                onSubmit: { performLogin() },
                isFocused: $isPasswordFocused
            )
            .staggeredFadeIn(index: 2)
        }
    }

    private var forgotPasswordLink: some View {
        HStack {
            Spacer()
            Button("Lupa Password?") {
                showForgotPassword = true
            }
            .font(.ionCaption)
            .foregroundStyle(Color.brandPrimary)
        }
        .staggeredFadeIn(index: 3)
    }

    private var loginButton: some View {
        IONPrimaryButton(
            "Masuk",
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid
        ) {
            performLogin()
        }
        .staggeredFadeIn(index: 4)
    }

    // MARK: - Actions

    private func performLogin() {
        guard viewModel.isFormValid else { return }
        isEmailFocused = false
        isPasswordFocused = false
        Task {
            await viewModel.login()
        }
    }
}
