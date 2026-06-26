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
public import Memory_Heap_Primitives
public import Memory_Inline_Primitives
public import Memory_Primitive
public import Memory_Region_Primitives

// MARK: - Region (element-free raw-region seam — delegates to the active arm)
//
// `Memory.Small` is the sum type `Memory.Inline ⊕ Memory.Heap`; both arms are `Memory.Region`
// leaves, so the region seam delegates `base`/`capacity` to whichever arm is active. Per
// `Memory.Region`'s invariant it exposes base + capacity ONLY — element typing, slot identity,
// and the initialization ledger are lifted at `Storage.Contiguous`, never on the raw region.
// This is what makes `Memory.Small` swap-compatible with `Memory.Heap` / `Memory.Inline` as an
// allocator `Resource` (`Memory.Allocator<Memory.Small<n>>`).

extension Memory.Small: Memory.Region {
    /// The stable base address of the active arm's first byte.
    @inlinable
    public var base: Memory.Address {
        switch _storage {
        case .inline(let arm): arm.base
        case .heap(let arm): arm.base
        }
    }

    /// The active arm's capacity in bytes.
    @inlinable
    public var capacity: Memory.Address.Count {
        switch _storage {
        case .inline(let arm): arm.capacity
        case .heap(let arm): arm.capacity
        }
    }
}
