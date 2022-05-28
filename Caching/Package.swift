// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Caching",
    products: [
        .library(
            name: "Caching",
            targets: ["Caching"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.27.0")
    ],
    targets: [
        .target(
            name: "Caching",
            dependencies: [
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift")
            ])
    ]
)
