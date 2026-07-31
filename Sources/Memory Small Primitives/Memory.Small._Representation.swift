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

public import Memory_Heap_Primitives
public import Memory_Inline_Primitives
public import Memory_Primitive

extension Memory.Small {
    /// The active storage arm.
    ///
    /// The enum (not a two-field struct) is release-correctness-load-bearing — see the type doc.
    @frozen
    @usableFromInline
    package enum _Representation: ~Copyable {
        /// Inline arm: the `@_rawLayout` inline raw-byte leaf (element-free).
        case inline(Memory.Inline<inlineCapacity>)
        /// Heap arm: the out-of-line `Memory.Heap` raw-byte leaf (the spill target).
        case heap(Memory.Heap)
    }
}
