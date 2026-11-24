// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

let uiSwiftSettings = swiftSettings + [
    .defaultIsolation(MainActor.self),
]

let package = Package(
    name: "Modules",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "OpenMeteo", targets: ["OpenMeteo"]),
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "WeatherUI", targets: ["WeatherUI"]),
    ],
    targets: [
        .target(name: "Domain", swiftSettings: swiftSettings),
        .target(name: "Networking", swiftSettings: swiftSettings),
        .target(name: "OpenMeteo", dependencies: ["Domain", "Networking"], swiftSettings: swiftSettings),
        .target(name: "Persistence", dependencies: ["Domain"], swiftSettings: swiftSettings),
        .target(name: "DesignSystem", resources: [.process("Resources")], swiftSettings: uiSwiftSettings),
        .target(
            name: "WeatherUI",
            dependencies: ["Domain"],
            resources: [.process("Resources")],
            swiftSettings: swiftSettings
        ),
        .testTarget(name: "DomainTests", dependencies: ["Domain"], swiftSettings: swiftSettings),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"], swiftSettings: swiftSettings),
        .testTarget(
            name: "OpenMeteoTests",
            dependencies: ["OpenMeteo", "Domain", "Networking"],
            swiftSettings: swiftSettings
        ),
        .testTarget(name: "PersistenceTests", dependencies: ["Persistence", "Domain"], swiftSettings: swiftSettings),
        .testTarget(name: "WeatherUITests", dependencies: ["WeatherUI"], swiftSettings: swiftSettings),
    ]
)
