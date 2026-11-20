// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MomentCore",
    defaultLocalization: "en",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "MomentCore", targets: ["MomentCore"]),
    ],
    targets: [
        .target(
            name: "MomentCore",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "MomentCoreTests",
            dependencies: ["MomentCore"]
        ),
    ]
)
