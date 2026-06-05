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

public import Index_Primitives
public import Memory_Heap_Primitives
public import Memory_Inline_Primitives
public import Memory_Primitive

extension Memory.Small where Element: ~Copyable {
    /// Reconstructs storage from a `_Representation`.
    ///
    /// The full-reassignment seat (`self = Self(_storage:)`) is how `~Copyable` enum payloads are
    /// mutated in place — destructure via `case .arm(var x)`, operate, then reassign `self`.
    @inlinable
    init(_storage: consuming _Representation) {
        self._storage = _storage
    }

    /// The total slot capacity currently available — DYNAMIC: the inline arm's fixed capacity
    /// while inline, or the heap arm's capacity once spilled. The spill is leaf-internal, so a
    /// fixed-`inlineCapacity` `Small` still grows unboundedly.
    ///
    /// Witnesses `Store.`Protocol``'s `capacity` requirement by delegating to the active arm.
    @inlinable
    public var capacity: Index<Element>.Count {
        switch _storage {
        case .inline(let arm):
            arm.capacity
        case .heap(let arm):
            arm.capacity
        }
    }

    /// Whether storage has spilled from the inline arm to the heap arm.
    ///
    /// Spill-state is leaf-local: only `Memory.Small` has a spill concept, so it lives here.
    @inlinable
    public var isSpilled: Bool {
        switch _storage {
        case .inline: false
        case .heap: true
        }
    }
}
