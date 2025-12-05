import Foundation

struct AppItem: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var path: String
    var bundleIdentifier: String?

    init(id: UUID = UUID(), name: String, path: String, bundleIdentifier: String?) {
        self.id = id
        self.name = name
        self.path = path
        self.bundleIdentifier = bundleIdentifier
    }
}

enum LaunchItem: Identifiable, Hashable, Codable {
    case app(AppItem)
    case folder(FolderItem)

    var id: UUID {
        switch self {
        case .app(let app): return app.id
        case .folder(let folder): return folder.id
        }
    }

    var displayName: String {
        switch self {
        case .app(let app): return app.name
        case .folder(let folder): return folder.name
        }
    }
}

struct FolderItem: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var apps: [AppItem]

    init(id: UUID = UUID(), name: String, apps: [AppItem]) {
        self.id = id
        self.name = name
        self.apps = apps
    }
}

