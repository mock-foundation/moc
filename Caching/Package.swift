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
            .revisionItem("e78aef926cdd92323755bcb72309aa5afed1f02a")
        ),
        .package(url: "https://github.com/hyperoslo/Cache.git", .exactItem(.init(6, 0, 0)))
    ],
    targets: [.target(
            name: "Caching",
            dependencies: [
                "TDLibKit",
                "Cache"
            ]),
    ]
)
