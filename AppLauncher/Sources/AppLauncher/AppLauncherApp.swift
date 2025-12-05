import SwiftUI

@main
struct AppLauncherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = LauncherViewModel()

    var body: some Scene {
        WindowGroup {
            LauncherView()
                .environmentObject(viewModel)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
