// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Generated",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Generated",
            targets: ["Generated"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Generated",
            dependencies: [])
    ]
)
