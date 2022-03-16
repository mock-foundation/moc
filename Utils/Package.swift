// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Utils",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Utils",
            targets: ["Utils"]),
    ],
    dependencies: [],
    targets: [
        .plugin(
            name: "GeneratorPlugin",
            capability: .buildTool()
        ),
        .target(
            name: "Utils",
            dependencies: [],
            plugins: [
                .plugin(name: "GeneratorPlugin")
            ]
        ),
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"]),
//        .binaryTarget(
//            name: "Sourcery",
//            url: "https://github.com/krzysztofzablocki/Sourcery/releases/download/1.7.0/Sourcery-1.7.0.zip",
//            checksum: "8c1a73e642c31583eae6fb63d2f41cea255bf6c315dfa9e1d81f45d985b3e346"
//        ),
    ]
)
