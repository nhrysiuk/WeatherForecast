// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
    name: "Modules",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "OpenMeteo", targets: ["OpenMeteo"]),
    ],
    targets: [
        .target(name: "Domain", swiftSettings: swiftSettings),
        .target(name: "Networking", swiftSettings: swiftSettings),
        .target(name: "OpenMeteo", dependencies: ["Domain", "Networking"], swiftSettings: swiftSettings),
        .testTarget(name: "DomainTests", dependencies: ["Domain"], swiftSettings: swiftSettings),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"], swiftSettings: swiftSettings),
        .testTarget(
            name: "OpenMeteoTests",
            dependencies: ["OpenMeteo", "Domain", "Networking"],
            swiftSettings: swiftSettings
        ),
    ]
)
