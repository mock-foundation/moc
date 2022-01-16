// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SystemUtils",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SystemUtils",
            targets: ["SystemUtils"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SystemUtils",
            dependencies: [],
            resources: []
        )
    ]
)
