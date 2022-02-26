// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Utils",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Utils",
            targets: ["Utils"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Utils",
            dependencies: []),
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"]),
    ]
)
