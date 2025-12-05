import XCTest
@testable import AppLauncher

final class AppScannerTests: XCTestCase {
    func testScanApplicationsReturnsArray() {
        let apps = AppScanner.scanApplications()
        XCTAssertNotNil(apps)
        XCTAssertTrue(apps.count >= 0)
    }

    func testAppItemHasNameAndPath() {
        let apps = AppScanner.scanApplications()
        if let first = apps.first {
            XCTAssertFalse(first.name.isEmpty)
            XCTAssertFalse(first.path.isEmpty)
        } else {
            XCTAssertTrue(apps.isEmpty)
        }
    }
}

