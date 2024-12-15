// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CrashKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "CrashKit",
            targets: ["CrashKit"]),
    ],
    dependencies: [
        // Add the Telemetric package from the sentryco GitHub repository
        .package(url: "https://github.com/sentryco/Telemetric.git", branch: "main")
    ],
    targets: [
        .target(
            name: "CrashKit"),
        .testTarget(
            name: "CrashKitTests",
            dependencies: ["CrashKit", "Telemetric"]), // Add Telemetric as a dependency to the CrashKitTests target
    ]
)
