// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Utilities",
            targets: ["Utilities"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Utilities",
            dependencies: [])
    ]
)
