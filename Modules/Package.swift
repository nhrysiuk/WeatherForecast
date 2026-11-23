// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
    ],
    targets: [
        .target(name: "Domain"),
    ]
)
