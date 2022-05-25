// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Logs",
    platforms: [
        .macOS(.v12)
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
