import SwiftUI

struct GoogleSignInButton: View {
    let isLoading: Bool
    let action: () -> Void

    init(isLoading: Bool = false, action: @escaping () -> Void) {
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: IONDesign.Spacing.sm) {
                if isLoading {
                    ProgressView()
                } else {
                    Image("ic_google")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)

                    Text("Lanjutkan dengan Google")
                        .font(.ion(14, weight: .semibold))
                }
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: IONDesign.Sizing.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: IONDesign.Radius.sm)
                    .fill(Color(red: 0x2B/255, green: 0x2B/255, blue: 0x2B/255).opacity(0x08/255))
            )
        }
        .buttonStyle(.pressScale)
        .disabled(isLoading)
    }
}
