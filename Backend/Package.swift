// swift-tools-version: 5.7

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
        .package(path: "../third-party/tdlibkit"),
        .package(path: "../third-party/Resolver"),
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
