// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-memory-small-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Memory Small Primitives",
            targets: ["Memory Small Primitives"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-memory-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-heap-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-inline-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-span-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-affine-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ordinal-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-store-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Hybrid inline⊕heap memory leaf (the third leaf; dissolves Storage.Small)
        .target(
            name: "Memory Small Primitives",
            dependencies: [
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(name: "Memory Inline Primitives", package: "swift-memory-inline-primitives"),
                .product(name: "Span Protocol Primitives", package: "swift-span-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Affine Primitives Standard Library Integration", package: "swift-affine-primitives"),
                .product(name: "Ordinal Primitives Standard Library Integration", package: "swift-ordinal-primitives"),
                .product(name: "Store Primitive", package: "swift-store-primitives"),
                .product(name: "Store Protocol Primitives", package: "swift-store-primitives"),
                .product(name: "Store Tracked Primitives", package: "swift-store-primitives"),
                .product(name: "Store Creatable Primitives", package: "swift-store-primitives"),
                .product(name: "Store Initialization Primitives", package: "swift-store-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("RawLayout"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
