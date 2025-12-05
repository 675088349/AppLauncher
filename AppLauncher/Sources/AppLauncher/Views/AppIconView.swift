import SwiftUI
import AppKit

struct AppIconView: View {
    let item: LaunchItem
    @State private var icon: NSImage? = nil
    @State private var isHovering: Bool = false
    @Namespace private var bounceNS

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let img = icon {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isHovering ? 1.06 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: isHovering)
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(width: 80, height: 80)
                }
            }
            Text(item.displayName)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(width: 96, height: 110)
        .onHover { hovering in isHovering = hovering }
        .task { loadIcon() }
    }

    private func loadIcon() {
        switch item {
        case .app(let app):
            IconCache.shared.icon(for: app.path, size: NSSize(width: 128, height: 128)) { image in
                icon = image
            }
        case .folder:
            let folderImage = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil)
            icon = folderImage
        }
    }
}

