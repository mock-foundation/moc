// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Backend",
            targets: ["Backend"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/mock-foundation/tdlibkit.git",
            exact: "2.1.1-1.8.4-1dec0e20"
        ),
        .package(url: "https://github.com/hmlongco/Resolver.git", from: "1.0.0"),
        .package(path: "../Utilities"),
        .package(path: "../Caching"),
        .package(path: "../Logs")
    ],
    targets: [.target(
        name: "Backend",
        dependencies: [
            .product(name: "TDLibKit", package: "tdlibkit"),
            "Utilities",
            "Caching",
            "Logs",
            "Resolver"
        ]
    )]
)
