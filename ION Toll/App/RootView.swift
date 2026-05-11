import SwiftUI
import GoogleSignIn
#if canImport(PulseUI)
import PulseUI
#endif

struct RootView: View {
    @State private var sessionManager = SessionManager()
    @State private var router: AppRouter
    #if DEBUG
    @State private var showPulseConsole = false
    #endif

    init() {
        let session = SessionManager()
        self._sessionManager = State(wrappedValue: session)
        self._router = State(wrappedValue: AppRouter(sessionManager: session))
    }

    var body: some View {
        Group {
            switch router.rootRoute {
            case .onboarding:
                OnboardingView(viewModel: OnboardingViewModel(
                    authRepository: AuthRepository(),
                    sessionManager: sessionManager,
                    router: router
                ))
                .transition(.opacity)

            case .login:
                NavigationStack {
                    LoginView(viewModel: LoginViewModel(
                        authRepository: AuthRepository(),
                        sessionManager: sessionManager,
                        router: router
                    ))
                }
                .transition(.opacity)

            case .register:
                NavigationStack {
                    RegisterView(viewModel: RegisterViewModel(
                        sessionManager: sessionManager,
                        router: router
                    ))
                }
                .transition(.opacity)

            case .forgotPassword:
                NavigationStack {
                    ForgotPasswordView()
                }
                .transition(.opacity)

            case .resetPassword(let token):
                NavigationStack {
                    ResetPasswordView(token: token)
                }
                .transition(.opacity)

            case .phoneInput:
                NavigationStack {
                    PhoneInputView(sessionManager: sessionManager, router: router)
                }
                .transition(.opacity)

            case .otpVerification(let phoneNumber, let token):
                NavigationStack {
                    OtpVerificationView(
                        phoneNumber: phoneNumber,
                        token: token,
                        sessionManager: sessionManager,
                        router: router
                    )
                }
                .transition(.opacity)

            case .mainTab:
                MainTabView(sessionManager: sessionManager, router: router)
                    .transition(.opacity)

            default:
                MainTabView(sessionManager: sessionManager, router: router)
                    .transition(.opacity)
            }
        }
        .animation(.spring(duration: 0.5, bounce: 0.1), value: router.rootRoute)
        .onOpenURL { url in
            GIDSignIn.sharedInstance.handle(url)
            handleDeepLink(url)
        }
        #if DEBUG
        .overlay(alignment: .bottomTrailing) {
            Button {
                showPulseConsole.toggle()
            } label: {
                Image(systemName: "network")
                    .font(.title2)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding()
            .sheet(isPresented: $showPulseConsole) {
                NavigationStack {
                    ConsoleView()
                }
            }
        }
        #endif
    }

    private func handleDeepLink(_ url: URL) {
        guard url.host == "reset-password" else { return }
        let token = url.queryParameters?["token"] ?? ""
        if !token.isEmpty {
            router.replace(with: .resetPassword(token: token))
        }
    }
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return nil }
        return Dictionary(uniqueKeysWithValues: queryItems.compactMap { item in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
    }
}

#Preview {
    RootView()
}
