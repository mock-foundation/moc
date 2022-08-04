// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Caching",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Caching",
            targets: ["Caching"]),
    ],
    dependencies: [
        .package(path: "../third-party/GRDB.swift"),
        .package(path: "../Utilities"),
        .package(path: "../Logs")
    ],
    targets: [
        .target(
            name: "Caching",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                "Utilities",
                "Logs"
            ])
    ]
)
