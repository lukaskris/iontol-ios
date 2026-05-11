import SwiftUI

struct PinView: View {
    @State private var viewModel: PinViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    init(sessionManager: SessionManager, router: AppRouter, isSkippable: Bool = false) {
        self._viewModel = State(wrappedValue: PinViewModel(
            sessionManager: sessionManager,
            router: router,
            isSkippable: isSkippable
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 8)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

            PinDotsView(pinLength: viewModel.pinLength, filledCount: viewModel.currentPinCount)
                .padding(.top, 28)
                .animation(.spring(duration: 0.25), value: viewModel.currentPinCount)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)

            IONErrorBanner(message: viewModel.errorMessage)
                .padding(.top, 12)

            PinNumpadView(
                onDigit: { viewModel.addDigit($0) },
                onDelete: { viewModel.deleteDigit() }
            )
            .padding(.top, 28)
            .padding(.horizontal, IONDesign.Spacing.xl)

            IONPrimaryButton(
                viewModel.step == .create ? "Lanjutkan" : "Atur PIN",
                isLoading: viewModel.isLoading,
                isDisabled: !viewModel.isPinComplete
            ) {
                viewModel.submit()
            }
            .padding(.horizontal, IONDesign.Spacing.xl)
            .padding(.top, 24)
            .padding(.bottom, IONDesign.Spacing.xxl)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.brandPrimary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Skip") {
                    viewModel.skip()
                }
                .font(.ionSubheadline)
                .foregroundStyle(Color.brandPrimary)
            }
        }
        .loadingOverlay(viewModel.isLoading)
        .onAppear {
            viewModel.onComplete = { dismiss() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appeared = true
            }
        }
    }

    private var header: some View {
        VStack(spacing: IONDesign.Spacing.sm) {
            Text("PIN Transaksi")
                .font(.ionTitle2)
                .foregroundStyle(Color.brandPrimary)

            Text(viewModel.subtitle)
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, IONDesign.Spacing.xl)
    }
}
