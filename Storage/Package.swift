// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Storage",
            targets: ["Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "5.26.0"),
        .package(path: "../Utilities"),
        .package(path: "../Logs")
    ],
    targets: [
        .target(
            name: "Storage",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                "Utilities",
                "Logs"
            ])
    ]
)
