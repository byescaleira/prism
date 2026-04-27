// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Prism",
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
            name: "Prism",
            targets: ["Prism"],
        ),
        .library(
            name: "PrismFoundation",
            targets: ["PrismFoundation"],
        ),
        .library(
            name: "PrismNetwork",
            targets: ["PrismNetwork"],
        ),
        .library(
            name: "PrismArchitecture",
            targets: ["PrismArchitecture"],
        ),
        .library(
            name: "PrismUI",
            targets: ["PrismUI"],
        ),
        .library(
            name: "PrismVideo",
            targets: ["PrismVideo"],
        ),
        .library(
            name: "PrismIntelligence",
            targets: ["PrismIntelligence"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "Prism",
            dependencies: [
                "PrismFoundation",
                "PrismNetwork",
                "PrismArchitecture",
                "PrismUI",
                "PrismVideo",
                "PrismIntelligence",
            ],
        ),
        .target(name: "PrismFoundation"),
        .target(
            name: "PrismNetwork",
            dependencies: ["PrismFoundation"],
            resources: [
                .process("Resource/PrismNetworkString.xcstrings"),
                .process("Resource/PrismNetworkLogMessage.xcstrings"),
            ],
        ),
        .target(
            name: "PrismArchitecture",
            dependencies: ["PrismFoundation"],
        ),
        .target(
            name: "PrismUI",
            dependencies: [
                "PrismFoundation",
                "PrismArchitecture",
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
            name: "PrismVideo",
            dependencies: ["PrismFoundation"],
        ),
        .target(
            name: "PrismIntelligence",
            dependencies: ["PrismFoundation"],
        ),
        .target(
            name: "PrismPreview",
            dependencies: ["Prism"],
        ),
        .testTarget(
            name: "PrismFoundationTests",
            dependencies: ["PrismFoundation"],
        ),
        .testTarget(
            name: "PrismArchitectureTests",
            dependencies: [
                "PrismArchitecture",
                "PrismUI",
            ],
        ),
        .testTarget(
            name: "PrismNetworkTests",
            dependencies: ["PrismNetwork"],
        ),
        .testTarget(
            name: "PrismUITests",
            dependencies: [
                "PrismUI",
                "PrismArchitecture",
            ],
        ),
        .testTarget(
            name: "PrismIntelligenceTests",
            dependencies: [
                "PrismIntelligence",
                "PrismFoundation",
            ],
        ),
        .testTarget(
            name: "PrismVideoTests",
            dependencies: [
                "PrismVideo",
                "PrismFoundation",
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
