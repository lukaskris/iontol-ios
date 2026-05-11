import SwiftUI

struct OtpVerificationView: View {
    @State private var viewModel: OtpVerificationViewModel
    @State private var shakeOffset: CGFloat = 0
    @State private var otpText = ""
    @State private var showToast = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFieldFocused: Bool

    private let otpLength = 5

    init(phoneNumber: String, token: String?, sessionManager: SessionManager, router: AppRouter) {
        self._viewModel = State(wrappedValue: OtpVerificationViewModel(
            phoneNumber: phoneNumber,
            token: token,
            sessionManager: sessionManager,
            router: router
        ))
    }

    var body: some View {
        VStack(spacing: IONDesign.Spacing.xl) {
            header

            otpBoxes

            errorMessage

            verifyButton

            resendSection

            Spacer()
        }
        .padding(.horizontal, IONDesign.Spacing.xl)
        .padding(.top, 40)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(Color.brandPrimary)
                }
            }
        }
        .ionToast(isPresented: $showToast, message: "Berhasil Verifikasi Kode OTP. Silakan masuk ke akun untuk melanjutkan.", style: .success)
        .onAppear { isFieldFocused = true }
        .onChange(of: otpText) {
            // Only allow digits, max 5
            let filtered = otpText.filter { $0.isNumber }
            if filtered != otpText || filtered.count > otpLength {
                otpText = String(filtered.prefix(otpLength))
            }
            // Auto-submit when all 5 digits filled
            if otpText.count == otpLength {
                isFieldFocused = false
                viewModel.otp = otpText
                Task { await viewModel.verify() }
            }
        }
        .onChange(of: viewModel.errorMessage) {
            if viewModel.errorMessage != nil {
                otpText = ""
                triggerShake()
            }
        }
        .onChange(of: viewModel.isVerified) {
            if viewModel.isVerified {
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    viewModel.router.shouldAutoShowLogin = true
                    viewModel.router.replace(with: .onboarding)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: IONDesign.Spacing.sm) {
            Text("Verifikasi Kode OTP")
                .font(.ionTitle3)
                .foregroundStyle(Color.brandPrimary)
            Text("Silahkan masukan kode OTP yang telah dikirim ke nomor \(viewModel.phoneNumber)")
                .font(.ionCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .staggeredFadeIn(index: 0)
    }

    // MARK: - OTP Boxes

    private var otpBoxes: some View {
        HStack(spacing: 12) {
            ForEach(0..<otpLength, id: \.self) { index in
                otpDigitBox(index: index)
            }
        }
        .modifier(ShakeEffect(animatableData: shakeOffset))
        .staggeredFadeIn(index: 1)
        .onTapGesture { isFieldFocused = true }
    }

    private func otpDigitBox(index: Int) -> some View {
        ZStack {
            // Hidden text field that captures all input
            TextField("", text: $otpText)
                .focused($isFieldFocused)
                .keyboardType(.numberPad)
                .font(.ionTitle2)
                .multilineTextAlignment(.center)
                .opacity(0.01) // invisible but functional
                .frame(width: 52, height: 56)

            // Visible digit display
            Text(digit(at: index))
                .font(.ionTitle2)
                .foregroundStyle(.primary)
        }
        .frame(width: 52, height: 56)
        .background(
            RoundedRectangle(cornerRadius: IONDesign.Radius.md)
                .stroke(borderColor(for: index), lineWidth: 1.5)
        )
    }

    private func digit(at index: Int) -> String {
        guard otpText.count > index else { return "" }
        return String(otpText[otpText.index(otpText.startIndex, offsetBy: index)])
    }

    private func borderColor(for index: Int) -> SwiftUI.Color {
        if viewModel.errorMessage != nil {
            return .red
        }
        let currentIndex = otpText.count
        if isFieldFocused && index == currentIndex {
            return Color.brandPrimary
        }
        if index < otpText.count {
            return Color.brandPrimary.opacity(0.5)
        }
        return Color(.separator)
    }

    // MARK: - Error Message

    private var errorMessage: some View {
        Group {
            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.ionFootnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
    }

    // MARK: - Verify Button

    private var verifyButton: some View {
        IONPrimaryButton(
            "Verifikasi",
            isLoading: viewModel.isLoading,
            isDisabled: otpText.count != otpLength
        ) {
            isFieldFocused = false
            viewModel.otp = otpText
            Task { await viewModel.verify() }
        }
        .staggeredFadeIn(index: 2)
    }

    // MARK: - Resend Section

    private var resendSection: some View {
        VStack(spacing: IONDesign.Spacing.sm) {
            if viewModel.canResend {
                Button("Kirim Ulang Kode OTP") {
                    Task { await viewModel.resendOtp() }
                }
                .font(.ionSubheadline)
                .foregroundStyle(Color.brandPrimary)
            } else {
                Text("Kirim ulang dalam \(viewModel.resendCooldown / 60):\((viewModel.resendCooldown % 60 < 10 ? "0" : "") + "\(viewModel.resendCooldown % 60)")")
                    .font(.ionCaption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(.top, IONDesign.Spacing.md)
        .staggeredFadeIn(index: 4)
    }

    // MARK: - Actions

    private func triggerShake() {
        guard viewModel.errorMessage != nil else { return }
        withAnimation(.spring(duration: 0.4, bounce: 0.4)) {
            shakeOffset = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            shakeOffset = 0
        }
    }
}
