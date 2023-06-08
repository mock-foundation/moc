// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Logs",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Logs",
            targets: ["Logs"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Logs",
            dependencies: [])
    ]
)
