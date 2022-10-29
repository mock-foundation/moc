// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "L10n",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "L10n",
            targets: ["L10n"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Decybel07/L10n-swift.git", from: "5.10.0"),
        .package(url: "https://github.com/mock-foundation/tdlibkit", from: "3.0.2-1.8.4-07b7faf6"),
        .package(path: "../Backend"),
        .package(path: "../Logs")
    ],
    targets: [
        .target(
            name: "L10n",
            dependencies: [
                "L10n-swift",
                .product(name: "TDLibKit", package: "tdlibkit"),
                "Backend",
                "Logs"
            ],
            resources: [
                .copy("Localizable.strings")
            ]),
        .testTarget(
            name: "L10nTests",
            dependencies: ["L10n"]),
    ]
)
