// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AppLauncher",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "AppLauncher", targets: ["AppLauncher"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "AppLauncher",
            path: "Sources/AppLauncher"
        ),
        .testTarget(
            name: "AppLauncherTests",
            dependencies: ["AppLauncher"],
            path: "Tests/AppLauncherTests"
        )
    ]
)

