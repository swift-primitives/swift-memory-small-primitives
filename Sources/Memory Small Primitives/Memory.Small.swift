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

extension Memory {
    /// Hybrid inline⊕heap memory leaf — stores up to `inlineCapacity` elements inline (no
    /// allocation) and spills to a heap allocation when that capacity is exceeded.
    ///
    /// `Memory.Small<Element, inlineCapacity>` is the third allocation-strategy leaf of the
    /// substitution tower (with ``Memory/Heap`` and ``Memory/Inline``). **"Small" is a MEMORY
    /// concern**: the topology stays contiguous whether inline or spilled — only the byte
    /// LOCATION switches inline⊕heap. It composes the two leaves; `Storage.Contiguous<Memory.Small<E,n>>`
    /// is the dense discipline the buffers compose — replacing the dissolved `Storage.Small`.
    ///
    /// ## The lifecycle split
    ///
    /// `Memory.Small` owns the LOCATION, the discriminant, and the spill-DECISION (when to move
    /// from inline to heap — see `create`). `Storage.Contiguous` (which has the count) owns MOVING
    /// the live elements on spill — identical to how `Memory.Heap` growth splits (the leaf provides
    /// the region; the discipline moves elements).
    ///
    /// ## Representation
    ///
    /// A `~Copyable` discriminated union — never a two-field struct: mixing the `@_rawLayout`
    /// inline arm with the heap arm's class reference in one struct trips an LLVM release verifier
    /// crash ("Instruction does not dominate all uses!"); the enum destroys exactly one arm.
    ///
    /// - `inline`: `Memory.Inline<Element, inlineCapacity>` — the `@_rawLayout` + ledger inline leaf.
    /// - `heap`: `Memory.Heap<Element>` — the class-backed leaf, reused as the spill target.
    ///
    /// ## Copyability
    ///
    /// Unconditionally `~Copyable` (the `@_rawLayout` inline arm is unconditionally `~Copyable`).
    public struct Small<Element: ~Copyable, let inlineCapacity: Int>: ~Copyable {
        /// The active storage arm. The enum (not a two-field struct) is
        /// release-correctness-load-bearing — see the type doc.
        @frozen
        @usableFromInline
        enum _Representation: ~Copyable {
            /// Inline arm: the `@_rawLayout` + `Store.Initialization`-ledger inline leaf.
            case inline(Memory.Inline<Element, inlineCapacity>)
            /// Heap arm: the class-backed `Memory.Heap` leaf (the spill target).
            case heap(Memory.Heap<Element>)
        }

        @usableFromInline
        var _storage: _Representation

        /// Creates empty inline storage.
        @inlinable
        public init() {
            _storage = .inline(Memory.Inline<Element, inlineCapacity>())
        }
    }
}
