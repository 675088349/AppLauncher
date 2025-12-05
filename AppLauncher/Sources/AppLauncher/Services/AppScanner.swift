import Foundation
import AppKit

enum AppScanner {
    static func scanApplications() -> [AppItem] {
        print("Starting app scan...")
        var results: [AppItem] = []
        let fm = FileManager.default
        let searchPaths: [String] = [
            "/Applications",
//            "/System/Applications"
//            "/System/Applications/Utilities",
//            (fm.homeDirectoryForCurrentUser.path + "/Applications")
        ]

        for root in searchPaths {
            print("Scanning directory: \(root)")
            let rootURL = URL(fileURLWithPath: root)
            // Note: Some apps like Netease Youdao might be in subdirectories or have special permissions.
            // We removed skipsPackageDescendants to be safer, but added a check for .app.
            // Actually, Netease Youdao might be deep in /Applications.
            // Let's ensure we traverse subdirectories but don't enter .app packages.
            
            guard let enumerator = fm.enumerator(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
                print("Failed to create enumerator for \(root)")
                continue
            }
            
            for case let url as URL in enumerator {
                if url.pathExtension.lowercased() == "app" {
                    let name: String = appDisplayName(for: url) ?? url.deletingPathExtension().lastPathComponent
                    let bundleID: String? = Bundle(url: url)?.bundleIdentifier
                    results.append(AppItem(name: name, path: url.path, bundleIdentifier: bundleID))
                    print("Found app name = \(name)")
                    
                    if name.contains("有道") || name.contains("Youdao") {
                         print("Found Youdao: \(name) at \(url.path)")
                    }
                }
            }
        }

        print("Scan complete. Found \(results.count) apps.")
        
        // Deduplicate by bundle identifier or path
        var seen = Set<String>()
        let deduped = results.filter { item in
            let key = item.bundleIdentifier ?? item.path
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
        return deduped.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private static func appDisplayName(for url: URL) -> String? {
        if let bundle = Bundle(url: url) {
            if let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
                return displayName
            }
            if let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
                return name
            }
        }
        return nil
    }
}

