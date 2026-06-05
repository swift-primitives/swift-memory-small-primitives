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
    /// Creates storage sized for at least `minimumCapacity` elements — the spill DECISION.
    ///
    /// Starts inline when `minimumCapacity` fits the inline arm; otherwise allocates the heap arm
    /// directly (skipping the inline arm). Mirrors `Memory.Heap.create` so the buffer disciplines
    /// drive `Memory.Small` through the same growable-leaf surface.
    @inlinable
    public static func create(minimumCapacity: Index<Element>.Count) -> Self {
        if minimumCapacity <= Index<Element>.Count(UInt(inlineCapacity)) {
            Self(_storage: .inline(Memory.Inline<Element, inlineCapacity>()))
        } else {
            Self(_storage: .heap(Memory.Heap<Element>.create(minimumCapacity: minimumCapacity)))
        }
    }
}
