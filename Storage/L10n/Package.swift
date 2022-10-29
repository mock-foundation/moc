// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "L10n",
    products: [
        .library(
            name: "L10n",
            targets: ["L10n"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Decybel07/L10n-swift.git", from: "5.10")
    ],
    targets: [
        .target(
            name: "L10n",
            dependencies: [""]),
        .testTarget(
            name: "L10nTests",
            dependencies: ["L10n"]),
    ]
)
