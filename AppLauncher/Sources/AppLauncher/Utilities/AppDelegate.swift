import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApp.windows.first {
            configure(window: window)
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if let window = NSApp.windows.first {
            configure(window: window)
        }
    }

    func configure(window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        window.setFrame(screen.frame, display: false)
        window.styleMask = [.borderless, .fullSizeContentView]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .statusBar
        window.collectionBehavior = [.fullScreenNone, .moveToActiveSpace, .ignoresCycle]
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
