// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Backend",
            targets: ["Backend"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Resolver.git", from: "1.0.0"),
        .package(
            url: "https://github.com/mock-foundation/tdlibkit",
            revision: "4188caf0a914257f7884ce0b9e4ccc077f7db941"),
        .package(path: "../Utilities"),
        .package(path: "../Storage"),
        .package(path: "../Logs")
    ],
    targets: [.target(
        name: "Backend",
        dependencies: [
            .product(name: "TDLibKit", package: "tdlibkit"),
            "Utilities",
            "Storage",
            "Logs",
            "Resolver"
        ]
    )]
)
