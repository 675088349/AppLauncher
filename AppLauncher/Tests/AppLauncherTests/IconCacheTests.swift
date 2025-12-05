import XCTest
import AppKit
@testable import AppLauncher

final class IconCacheTests: XCTestCase {
    func testIconCacheLoadsIcon() {
        let apps = AppScanner.scanApplications()
        guard let app = apps.first else { return }

        let expectation = XCTestExpectation(description: "icon loaded")
        IconCache.shared.icon(for: app.path, size: NSSize(width: 64, height: 64)) { image in
            XCTAssertEqual(Int(image.size.width), 64)
            XCTAssertEqual(Int(image.size.height), 64)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}

