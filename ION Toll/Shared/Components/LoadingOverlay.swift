import SwiftUI

struct LoadingOverlay: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                        ProgressView()
                            .tint(.white)
                            .padding(32)
                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: isLoading)
                }
            }
    }
}

extension View {
    func loadingOverlay(_ isLoading: Bool) -> some View {
        modifier(LoadingOverlay(isLoading: isLoading))
    }
}
