// swift-tools-version:5.6

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
            dependencies: [])
    ]
)
