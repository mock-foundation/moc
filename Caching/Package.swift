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
    ],
    targets: [.target(
            name: "Caching",
            dependencies: ["TDLibKit"]),
    ]
)
