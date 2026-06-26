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
        .package(url: "https://github.com/swift-primitives/swift-memory-allocation-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-heap-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-inline-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Hybrid inline⊕heap memory leaf (the third leaf; dissolves Storage.Small)
        //
        // Post dependency-inversion the leaf depends on allocation-primitives to declare its
        // Memory.Allocatable adopt-role + Memory.Growable conformances (the latter's
        // init(byteCount:alignment:) IS the inline⊕heap spill decision). The element-typed ledger no
        // longer lives here (it lifted to Storage.Contiguous), so the prior Store.* / Memory.Tracked /
        // Memory.Allocatable (element-typed, now dissolved) deps are gone.
        .target(
            name: "Memory Small Primitives",
            dependencies: [
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Memory Region Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Address Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Alignment Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Allocator Protocol Primitives", package: "swift-memory-allocation-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(name: "Memory Inline Primitives", package: "swift-memory-inline-primitives"),
            ]
        ),
        .testTarget(
            name: "Memory Small Primitives Tests",
            dependencies: [
                "Memory Small Primitives",
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
