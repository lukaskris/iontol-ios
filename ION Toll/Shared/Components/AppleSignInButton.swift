import SwiftUI

struct AppleSignInButton: View {
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
                        .tint(.white)
                } else {
                    Image(systemName: "apple.logo")
                        .font(.body.weight(.semibold))
                    Text("Lanjutkan dengan Apple")
                        .font(.ion(14, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: IONDesign.Sizing.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: IONDesign.Radius.sm)
                    .fill(Color(red: 0x2B/255, green: 0x2B/255, blue: 0x2B/255))
            )
        }
        .buttonStyle(.pressScale)
        .disabled(isLoading)
    }
}
