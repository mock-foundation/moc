// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Utilities",
            targets: ["Utilities"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mock-foundation/macmodels.git", from: "2022.07.12")
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: [.product(name: "MacModels", package: "macmodels")])
    ]
)
