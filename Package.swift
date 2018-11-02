// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConveniencedLock",
    products: [
        .library(
            name: "ConveniencedLock",
            targets: ["ConveniencedLock"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ConveniencedLock",
            dependencies: [],
            path: "Sources/ConveniencedLock"
        ),
        .testTarget(
            name: "ConveniencedLockTests",
            dependencies: ["ConveniencedLock"]),
    ]
)
