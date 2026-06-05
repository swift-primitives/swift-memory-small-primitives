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

import Affine_Primitives_Standard_Library_Integration
public import Index_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Memory_Primitive
public import Store_Creatable_Primitives
public import Store_Primitive

// MARK: - Store.Creatable.Protocol conformance
//
// `Memory.Small` is a creatable store: `create(minimumCapacity:)` (Memory.Small+Create.swift) is the
// spill DECISION. The relocation below is the element-wise relocation over the neutral seam — the
// concrete witness (the storage-tier protocol-extension default cannot reach the memory tier). On
// spill, the discipline (`Storage.Contiguous`, which has the count) drives this; the ledger is
// synced by the caller, not here.

extension Memory.Small where Element: ~Copyable {
    /// Element-wise relocation of the initialized prefix `[0, count)` from `self` into
    /// `destination`, built only on the neutral seam (`move(at:)` + `initialize(at:to:)`).
    @inlinable
    public mutating func moveInitializePrefix(count: Index<Element>.Count, into destination: inout Self) {
        var slot: Index<Element> = .zero
        var moved: Index<Element>.Count = .zero
        while moved < count {
            destination.initialize(at: slot, to: move(at: slot))
            slot += .one
            moved = moved.add.saturating(.one)
        }
    }

    /// Element-wise wrap-around relocation: each element of `range` moves to
    /// `destinationOffset + (i - range.lowerBound)`. Used to linearize a wrapped ring.
    @inlinable
    public mutating func moveInitialize(
        range: Swift.Range<Index<Element>>,
        into destination: inout Self,
        at destinationOffset: Index<Element>
    ) {
        var source = range.lowerBound
        var dest = destinationOffset
        while source < range.upperBound {
            destination.initialize(at: dest, to: move(at: source))
            source += .one
            dest += .one
        }
    }
}

extension Memory.Small: Store.Creatable.`Protocol` where Element: ~Copyable {}
