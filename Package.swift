// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ryze",
    defaultLocalization: "pt",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .macCatalyst(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Ryze",
            targets: ["Ryze"],
        ),
        .library(
            name: "RyzeFoundation",
            targets: ["RyzeFoundation"],
        ),
        .library(
            name: "RyzeNetwork",
            targets: ["RyzeNetwork"],
        ),
        .library(
            name: "RyzeArchitecture",
            targets: ["RyzeArchitecture"],
        ),
        .library(
            name: "RyzeUI",
            targets: ["RyzeUI"],
        ),
        .library(
            name: "RyzeVideo",
            targets: ["RyzeVideo"],
        ),
        .library(
            name: "RyzeIntelligence",
            targets: ["RyzeIntelligence"],
        ),
    ],
    targets: [
        .target(
            name: "Ryze",
            dependencies: [
                "RyzeFoundation",
                "RyzeNetwork",
                "RyzeArchitecture",
                "RyzeUI",
                "RyzeVideo",
                "RyzeIntelligence",
            ],
        ),
        .target(name: "RyzeFoundation"),
        .target(
            name: "RyzeNetwork",
            dependencies: ["RyzeFoundation"],
            resources: [
                .process("Resource/RyzeNetworkString.xcstrings"),
                .process("Resource/RyzeNetworkLogMessage.xcstrings"),
            ],
        ),
        .target(
            name: "RyzeArchitecture",
            dependencies: ["RyzeFoundation"],
        ),
        .target(
            name: "RyzeUI",
            dependencies: [
                "RyzeFoundation",
                "RyzeArchitecture",
            ],
            exclude: [
                "Exports/README.md"
            ],
            resources: [
                .process("Resources/Localizable.xcstrings"),
                .process("Resources/Media.xcassets"),
                .copy("Resources/Symbols.json"),
            ],
        ),
        .target(
            name: "RyzeVideo",
            dependencies: ["RyzeFoundation"],
        ),
        .target(
            name: "RyzeIntelligence",
            dependencies: ["RyzeFoundation"],
        ),
        .target(
            name: "RyzePreview",
            dependencies: ["Ryze"],
        ),
        .executableTarget(
            name: "RyzePlayground",
            dependencies: [
                "Ryze",
                "RyzeUI",
                "RyzeArchitecture",
                "RyzeIntelligence",
            ],
            resources: [
                .process("Resources/Media.xcassets"),
            ],
        ),
        .testTarget(
            name: "RyzeFoundationTests",
            dependencies: ["RyzeFoundation"],
        ),
        .testTarget(
            name: "RyzeArchitectureTests",
            dependencies: [
                "RyzeArchitecture",
                "RyzeUI",
            ],
        ),
        .testTarget(
            name: "RyzeNetworkTests",
            dependencies: ["RyzeNetwork"],
        ),
        .testTarget(
            name: "RyzeUITests",
            dependencies: [
                "RyzeUI",
                "RyzeArchitecture",
            ],
        ),
        .testTarget(
            name: "RyzeIntelligenceTests",
            dependencies: [
                "RyzeIntelligence",
                "RyzeFoundation",
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
