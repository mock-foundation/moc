// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "MenuBar",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MenuBar",
            targets: ["MenuBar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/Defaults.git", from: "6.3.0"),
        .package(path: "../Utilities"),
        .package(path: "../L10n"),
        .package(path: "../Backend")
    ],
    targets: [
        .target(
            name: "MenuBar",
            dependencies: ["Defaults", "Utilities", "L10n"])
    ]
)
