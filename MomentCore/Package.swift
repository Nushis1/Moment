// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MomentCore",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "MomentCore", targets: ["MomentCore"]),
    ],
    targets: [
        .target(name: "MomentCore"),
        .testTarget(
            name: "MomentCoreTests",
            dependencies: ["MomentCore"]
        ),
    ]
)
