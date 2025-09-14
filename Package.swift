// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tca-kit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "TCAKit",
            targets: ["TCAKit"]
        ),
    ],
    targets: [
        .target(
            name: "TCAKit"
        ),
        .testTarget(
            name: "TCAKitTests",
            dependencies: ["TCAKit"]
        ),
    ]
)
