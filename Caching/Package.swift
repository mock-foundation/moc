// swift-tools-version:5.5

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
            .exact("1.2.1-tdlib-1.8.1-1e1ab5d1")
        ),
        .package(url: "https://github.com/hyperoslo/Cache.git", .upToNextMajor(from: "6.0.0"))
    ],
    targets: [.target(
            name: "Caching",
            dependencies: [
                "TDLibKit",
                "Cache"
            ]),
    ]
)
