import SwiftUI
import FirebaseCore

@main
struct ION_TollApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
