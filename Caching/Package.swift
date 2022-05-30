// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Caching",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Caching",
            targets: ["Caching"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "5.24.1"),
        .package(path: "../Utilities")
    ],
    targets: [
        .target(
            name: "Caching",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                "Utilities"
            ])
    ]
)
