// swift-tools-version:5.6

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
            exact: "1.2.1-tdlib-1.8.3-9c9a74c5"
        ),
        .package(url: "https://github.com/hmlongco/Resolver.git", from: "1.0.0"),
        .package(path: "../Utilities"),
        .package(path: "../Caching"),
        .package(path: "../Logs")
    ],
    targets: [.target(
        name: "Backend",
        dependencies: [
            "TDLibKit",
            "Utilities",
            "Caching",
            "Logs",
            "Resolver"
        ]
    )]
)
