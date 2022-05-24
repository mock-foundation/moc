// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Calls",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Calls",
            targets: ["Calls"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/TelegramMessenger/tgcalls.git",
            revision: "5dfa5925449e5279ba7e1b0a401b0678dea86dcc"
        )
    ],
    targets: [
        .target(
            name: "Calls",
            dependencies: [
                .product(name: "TgVoipWebrtc", package: "tgcalls")
            ]),
        .testTarget(
            name: "CallsTests",
            dependencies: ["Calls"]),
    ]
)
