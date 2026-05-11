import SwiftUI

struct ChangePinView: View {
    @State private var viewModel: ChangePinViewModel
    @Environment(\.dismiss) private var dismiss

    init(sessionManager: SessionManager) {
        self._viewModel = State(wrappedValue: ChangePinViewModel(sessionManager: sessionManager))
    }

    var body: some View {
        VStack(spacing: IONDesign.Spacing.xxl) {
            Spacer()

            VStack(spacing: IONDesign.Spacing.sm) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.brandPrimary)

                Text(viewModel.title)
                    .font(.ionTitle3)
                    .foregroundStyle(Color.brandPrimary)
            }

            PinDotsView(pinLength: viewModel.pinLength, filledCount: viewModel.currentPinCount)
                .animation(.spring(duration: 0.25), value: viewModel.currentPinCount)

            // Step indicator
            HStack(spacing: IONDesign.Spacing.xs) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index <= viewModel.step.rawValue ? Color.brandPrimary : Color(.separator))
                        .frame(width: 8, height: 8)
                }
            }

            IONErrorBanner(message: viewModel.errorMessage)

            Spacer()

            PinNumpadView(
                onDigit: { viewModel.addDigit($0) },
                onDelete: { viewModel.deleteDigit() }
            )
        }
        .padding(.horizontal, IONDesign.Spacing.xl)
        .padding(.bottom, IONDesign.Spacing.xxl)
        .navigationTitle("Ubah PIN")
        .navigationBarTitleDisplayMode(.inline)
        .loadingOverlay(viewModel.isLoading)
        .alert("Berhasil", isPresented: $viewModel.isSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("PIN berhasil diubah.")
        }
    }
}
