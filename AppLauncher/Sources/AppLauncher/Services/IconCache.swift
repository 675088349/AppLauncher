import Foundation
import AppKit

final class IconCache {
    static let shared = IconCache()
    private let cache = NSCache<NSString, NSImage>()
    private let queue = DispatchQueue(label: "icon-cache", qos: .userInitiated)

    func icon(for path: String, size: NSSize = NSSize(width: 128, height: 128), completion: @escaping (NSImage) -> Void) {
        let key = NSString(string: path + "-\(Int(size.width))x\(Int(size.height))")
        if let cached = cache.object(forKey: key) {
            completion(cached)
            return
        }
        queue.async {
            let image = NSWorkspace.shared.icon(forFile: path)
            let resized = image.resized(to: size)
            self.cache.setObject(resized, forKey: key)
            DispatchQueue.main.async {
                completion(resized)
            }
        }
    }
}

private extension NSImage {
    func resized(to targetSize: NSSize) -> NSImage {
        let img = NSImage(size: targetSize)
        img.lockFocus()
        let rect = NSRect(origin: .zero, size: targetSize)
        self.draw(in: rect, from: .zero, operation: .copy, fraction: 1.0)
        img.unlockFocus()
        return img
    }
}

