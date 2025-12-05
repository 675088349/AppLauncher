import Foundation
import Combine
import AppKit

final class LauncherViewModel: ObservableObject {
    @Published var items: [LaunchItem] = []
    @Published var filteredItems: [LaunchItem] = []
    @Published var searchText: String = "" {
        didSet { filterItems() }
    }
    @Published var currentPage: Int = 0
    @Published var pageCount: Int = 1
    @Published var isFolderOpen: Bool = false
    @Published var activeFolder: FolderItem?

    private var cancellables: Set<AnyCancellable> = []
    private let persistenceKey = "launcher.layout.v1"

    init() {
        loadLayout()
        let apps = AppScanner.scanApplications()
        mergeScannedApps(apps)
        filterItems()
    }

    private func mergeScannedApps(_ scanned: [AppItem]) {
        var currentApps: Set<String> = []
        // Collect existing bundle IDs/Paths including those in folders
        for item in items {
            switch item {
            case .app(let app):
                currentApps.insert(app.bundleIdentifier ?? app.path)
            case .folder(let folder):
                for app in folder.apps {
                    currentApps.insert(app.bundleIdentifier ?? app.path)
                }
            }
        }

        // Find new apps
        let newApps = scanned.filter { app in
            !currentApps.contains(app.bundleIdentifier ?? app.path)
        }

        // Add new apps to items
        if !newApps.isEmpty {
            items.append(contentsOf: newApps.map { LaunchItem.app($0) })
        }

        // Flatten empty/single-item folders caused by bugs
        items = items.compactMap { item in
            switch item {
            case .folder(let folder):
                if folder.apps.isEmpty { return nil }
                if folder.apps.count == 1 { return .app(folder.apps[0]) }
                return item
            default: return item
            }
        }
    }

    func filterItems() {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { item in
                item.displayName.localizedCaseInsensitiveContains(text)
            }
        }
        updatePageCount()
    }

    func updatePageCount(itemsPerPage: Int = 24) {
        let count = filteredItems.count
        let pages = (count + itemsPerPage - 1) / itemsPerPage
        pageCount = max(pages, 1)
        if currentPage >= pageCount {
            currentPage = pageCount - 1
        }
    }

    func pageItems(page: Int, itemsPerPage: Int) -> [LaunchItem] {
        let start = page * itemsPerPage
        let end = min(start + itemsPerPage, filteredItems.count)
        if start >= end { return [] }
        return Array(filteredItems[start..<end])
    }

    func launch(_ app: AppItem) {
        let url = URL(fileURLWithPath: app.path)
        NSWorkspace.shared.open(url)
        DispatchQueue.main.async {
            self.dismissWindow()
        }
    }

    func beginFolder(_ folder: FolderItem) {
        activeFolder = folder
        isFolderOpen = true
    }

    func closeFolder() {
        isFolderOpen = false
        activeFolder = nil
    }

    func dismissWindow() {
        NSApp.windows.forEach { $0.orderOut(nil) }
        NSApp.hide(nil)
    }

    func reorder(from: IndexSet, to: Int) {
        var base = items
        base.move(fromOffsets: from, toOffset: to)
        items = base
        filterItems()
        saveLayout()
    }

    func group(source: LaunchItem, target: LaunchItem) {
        // 不需要文件夹的逻辑，直接平铺开
        return
    }

    func addToFolder(app: AppItem, folder: FolderItem) {
        var base = items
        let folderIndex = base.firstIndex { item in
            switch item {
            case .folder(let f): return f.id == folder.id
            default: return false
            }
        }
        if let index = folderIndex {
            switch base[index] {
            case .folder(var f):
                f.apps.append(app)
                base[index] = .folder(f)
                items = base
                filterItems()
                saveLayout()
            default: break
            }
        }
    }

    func removeFromFolder(app: AppItem, folder: FolderItem) {
        var base = items
        let folderIndex = base.firstIndex { item in
            switch item {
            case .folder(let f): return f.id == folder.id
            default: return false
            }
        }
        if let index = folderIndex {
            switch base[index] {
            case .folder(var f):
                f.apps.removeAll { $0.id == app.id }
                if f.apps.count <= 1 {
                    if let remaining = f.apps.first {
                        base[index] = .app(remaining)
                    } else {
                        base.remove(at: index)
                    }
                } else {
                    base[index] = .folder(f)
                }
                items = base
                filterItems()
                saveLayout()
            default: break
            }
        }
    }

    func renameFolder(folder: FolderItem, name: String) {
        var base = items
        if let idx = base.firstIndex(where: { item in
            switch item {
            case .folder(let f): return f.id == folder.id
            default: return false
            }
        }) {
            switch base[idx] {
            case .folder(var f):
                f.name = name
                base[idx] = .folder(f)
                items = base
                filterItems()
                saveLayout()
            default: break
            }
        }
    }

    private func saveLayout() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: persistenceKey)
        }
    }

    private func loadLayout() {
//        if let data = UserDefaults.standard.data(forKey: persistenceKey) {
//            let decoder = JSONDecoder()
//            if let decoded = try? decoder.decode([LaunchItem].self, from: data) {
//                items = decoded
//            }
//        }
    }
}
