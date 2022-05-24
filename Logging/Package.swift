// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Logging",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Logging",
            targets: ["Logging"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Logging",
            dependencies: []),
        .testTarget(
            name: "LoggingTests",
            dependencies: ["Logging"]),
    ]
)
