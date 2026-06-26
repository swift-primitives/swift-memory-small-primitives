// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Memory_Address_Primitives
public import Memory_Alignment_Primitives
public import Memory_Allocator_Protocol_Primitives
public import Memory_Heap_Primitives
public import Memory_Inline_Primitives
public import Memory_Primitive

// MARK: - Memory.Growable (fresh byte-construction — THE SPILL DECISION)

extension Memory.Small: Memory.Growable {
    /// Allocates a `Memory.Small` sized for `byteCount` bytes — **this initializer is the spill
    /// decision**.
    ///
    /// A request that fits the inline budget stays inline (no allocation); a larger request
    /// spills to a fresh heap region:
    ///
    /// - `byteCount <= inlineCapacity` → `.inline(Memory.Inline<inlineCapacity>())` (the inline arm is
    ///   always exactly `inlineCapacity` bytes, which covers the smaller request).
    /// - otherwise → `.heap(Memory.Heap(byteCount:alignment:))` (an out-of-line region of exactly
    ///   `byteCount` bytes).
    ///
    /// `alignment` applies to the heap arm; the inline arm's alignment is fixed by its `@_rawLayout`
    /// storage layout.
    @inlinable
    public init(byteCount: Memory.Address.Count, alignment: Memory.Alignment) {
        let inlineBudget = Memory.Address.Count(UInt(inlineCapacity))
        if byteCount <= inlineBudget {
            self.init(_storage: .inline(Memory.Inline<inlineCapacity>()))
        } else {
            self.init(_storage: .heap(Memory.Heap(byteCount: byteCount, alignment: alignment)))
        }
    }
}

// MARK: - Memory.Allocatable (adopt-role)

/// `Memory.Small` adopts the allocation adopt-role: whichever arm is active (inline or spilled heap),
/// the whole region is wrapped as a passthrough `Memory.Allocator<Memory.Small<n>>` (the default
/// `makeAllocator()` adopts `self`).
///
/// Both arms expose the `Memory.Region` seam, so the passthrough reads `base`/`capacity` off the
/// active arm uniformly.
extension Memory.Small: Memory.Allocatable {}
