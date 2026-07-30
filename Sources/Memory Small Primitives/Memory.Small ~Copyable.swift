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

public import Memory_Primitive

extension Memory.Small {
    /// Reconstructs storage from a `_Representation`.
    ///
    /// The full-reassignment seat (`self = Self(_storage:)`) is how `~Copyable` enum payloads are
    /// mutated in place — destructure via `case .arm(var x)`, operate, then reassign `self`.
    @inlinable
    init(_storage: consuming _Representation) {
        self._storage = _storage
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
