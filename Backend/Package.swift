// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Backend",
            targets: ["Backend"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Swiftgram/TDLibKit.git",
            .exact("1.2.1-tdlib-1.8.3-9c9a74c5")
        ),
        .package(path: "../Caching"),
        .package(path: "../Utils"),
        .package(path: "../Logging")
    ],
    targets: [.target(
        name: "Backend",
        dependencies: [
            "TDLibKit",
            "Caching",
            "Utils",
            "Logging"
        ]
    )]
)
