// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Backend",
            targets: ["Backend"])
    ],
    dependencies: [],
    targets: [.target(
            name: "Backend",
            dependencies: [])
    ]
)
