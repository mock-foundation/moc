// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Backend",
            targets: ["Backend"])
    ],
    dependencies: [
        .package(url: "https://github.com/Swiftgram/TDLibKit.git", .revisionItem("e78aef926cdd92323755bcb72309aa5afed1f02a"))
    ],
    targets: [.target(
            name: "Backend",
            dependencies: ["TDLibKit"])
    ]
)
