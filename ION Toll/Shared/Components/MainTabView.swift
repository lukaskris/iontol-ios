import SwiftUI

struct MainTabView: View {
    let sessionManager: SessionManager
    let router: AppRouter

    var body: some View {
        NavigationStack {
            HomeView(sessionManager: sessionManager, router: router)
        }
    }
}

#Preview {
    MainTabView(
        sessionManager: SessionManager(),
        router: AppRouter(sessionManager: SessionManager())
    )
}
