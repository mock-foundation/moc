// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageUtils",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ImageUtils",
            targets: ["ImageUtils"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ImageUtils",
            dependencies: [])
    ]
)
