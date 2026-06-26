# Memory Small Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The hybrid inline⊕heap memory leaf for Swift — `Memory.Small` serves a byte region from inline storage with no allocation and spills to a `Memory.Heap` region only when its inline budget is exceeded.

---

## Quick Start

`Memory.Small<inlineCapacity>` is a `~Copyable` raw-byte region with two arms: an inline arm (`Memory.Inline<inlineCapacity>`, no allocation) and a heap arm (`Memory.Heap`, the spill target). It carries the *location* and the spill *decision* only — the element typing and initialization ledger lift to `Storage.Contiguous`, so the region itself stays element-free.

An empty region lives inline; no heap is touched:

```swift
import Memory_Small_Primitives

// An 8-byte inline budget: empty storage stays inline — no allocation.
let region = Memory.Small<8>()
print(region.isSpilled)   // false
```

The spill decision lives in one initializer: a request within the inline budget stays inline, a larger request allocates out of line.

```swift
import Memory_Address_Primitives
import Memory_Alignment_Primitives
import Memory_Small_Primitives

// 48 ≤ 64 → served inline, no heap allocation.
let small = Memory.Small<64>(byteCount: Memory.Address.Count(UInt(48)), alignment: .word)
print(small.isSpilled)   // false

// 256 > 64 → spills to a fresh Memory.Heap region.
let large = Memory.Small<64>(byteCount: Memory.Address.Count(UInt(256)), alignment: .word)
print(large.isSpilled)   // true
```

Both arms expose the same `Memory.Region` seam — `base` and `capacity` read off whichever arm is active — which makes `Memory.Small` swap-compatible with `Memory.Heap` and `Memory.Inline` as an allocator resource (`Memory.Allocator<Memory.Small<n>>`).

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-memory-small-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Memory Small Primitives", package: "swift-memory-small-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

One library product — the `Memory.Small` leaf. It composes the inline and heap raw-byte leaves and adopts the allocation roles (`Memory.Growable`, `Memory.Allocatable`, `Memory.Region`).

| Product | Target | Purpose |
|---------|--------|---------|
| `Memory Small Primitives` | `Sources/Memory Small Primitives/` | The `Memory.Small<inlineCapacity>` hybrid inline⊕heap region: the `init(byteCount:alignment:)` spill decision, the `isSpilled` discriminant, and the `base` / `capacity` region seam delegated to the active arm. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
