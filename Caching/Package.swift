// swift-tools-version:5.6

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
        .package(
            url: "https://github.com/Swiftgram/TDLibKit.git",
            exact: "1.2.1-tdlib-1.8.3-9c9a74c5"
        )
//        .package(url: "https://github.com/hyperoslo/Cache.git", exact: "6.0.0")
    ],
    targets: [
        .target(
            name: "Caching",
            dependencies: [
                "TDLibKit"
//                "Cache"
            ]
        ),
    ]
)
