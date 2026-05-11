import SwiftUI

struct OnboardingView: View {
    let viewModel: OnboardingViewModel
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var showOtp = false
    @State private var otpPhoneNumber = ""
    @State private var otpToken: String?
    @State private var isAppeared = false
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                heroSection
                Spacer()
                actionsSection
            }
            .padding(.horizontal, IONDesign.Spacing.xxl)
            .padding(.bottom, IONDesign.Spacing.lg)
            .navigationDestination(isPresented: $showLogin) {
                LoginView(viewModel: LoginViewModel(
                    authRepository: AuthRepository(),
                    sessionManager: viewModel.sessionManager,
                    router: viewModel.router
                ))
            }
            .navigationDestination(isPresented: $showRegister) {
                let registerVM = RegisterViewModel(
                    sessionManager: viewModel.sessionManager,
                    router: viewModel.router
                )
                RegisterView(viewModel: registerVM)
                    .onAppear {
                        registerVM.onNavigateToOtp = { phone, token in
                            otpPhoneNumber = phone
                            otpToken = token
                            showOtp = true
                        }
                    }
            }
            .navigationDestination(isPresented: $showOtp) {
                OtpVerificationView(
                    phoneNumber: otpPhoneNumber,
                    token: otpToken,
                    sessionManager: viewModel.sessionManager,
                    router: viewModel.router
                )
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

                if viewModel.router.shouldAutoShowLogin {
                    viewModel.router.shouldAutoShowLogin = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showLogin = true
                    }
                }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: IONDesign.Spacing.lg) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .staggeredFadeIn(index: 0)

            Text("ION Toll")
                .font(.ionTitle3)
                .foregroundStyle(Color.brandPrimary)
                .staggeredFadeIn(index: 1)

            Text("Dapatkan Info Yang Tepat Untuk Perjalanan Yang Lebih Nyaman")
                .font(.ionCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, IONDesign.Spacing.md)
                .staggeredFadeIn(index: 2)
        }
        .onAppear { isAppeared = true }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 14) {
            IONPrimaryButton("Masuk") {
                showLogin = true
            }
            .staggeredFadeIn(index: 3)

            IONSecondaryButton("Buat Akun") {
                showRegister = true
            }
            .staggeredFadeIn(index: 4)

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

            IONGhostButton(title: "Masuk sebagai tamu") {
                viewModel.loginAsGuest()
            }
            .padding(.top, IONDesign.Spacing.xs)
            .staggeredFadeIn(index: 8)
        }
    }
}
