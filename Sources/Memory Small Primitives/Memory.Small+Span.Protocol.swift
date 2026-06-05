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
public import Span_Protocol_Primitives
public import Store_Initialization_Primitives

// MARK: - Span / MutableSpan (~Copyable) — dispatch to the active arm
//
// The inline⊕heap union's contiguous view is the active arm's view. Both arms vend the same
// escape-hatch `pointer(at:)`, so the span is built over the live prefix (`arm.initialization.count`)
// and its lifetime is re-anchored to `self`.

extension Memory.Small where Element: ~Copyable {
    /// Safe, bounds-checked read access to the active arm's contiguous prefix.
    @inlinable
    public var span: Swift.Span<Element> {
        @_lifetime(borrow self)
        borrowing get {
            switch _storage {
            case .inline(let arm):
                let span = unsafe Swift.Span(
                    _unsafeStart: arm.pointer(at: .zero),
                    count: arm.initialization.count
                )
                return unsafe _overrideLifetime(span, borrowing: self)
            case .heap(let arm):
                let span = unsafe Swift.Span(
                    _unsafeStart: arm.pointer(at: .zero),
                    count: arm.initialization.count
                )
                return unsafe _overrideLifetime(span, borrowing: self)
            }
        }
    }

    /// Safe, bounds-checked write access to the active arm's contiguous prefix.
    @inlinable
    public var mutableSpan: Swift.MutableSpan<Element> {
        @_lifetime(&self)
        mutating get {
            // Extract base + live count into locals so the `_storage` read-borrow ends BEFORE
            // `_overrideLifetime` takes `&self` exclusively (avoids an exclusivity overlap).
            let start: UnsafeMutablePointer<Element>
            let count: Index<Element>.Count
            switch _storage {
            case .inline(let arm):
                start = unsafe arm.pointer(at: .zero)
                count = arm.initialization.count
            case .heap(let arm):
                start = unsafe arm.pointer(at: .zero)
                count = arm.initialization.count
            }
            let span = unsafe Swift.MutableSpan(_unsafeStart: start, count: count)
            return unsafe _overrideLifetime(span, mutating: &self)
        }
    }

    /// A mutable span over the first `count` elements (the caller is the count authority).
    @_lifetime(&self)
    @inlinable
    public mutating func mutableSpan(count: Index<Element>.Count) -> Swift.MutableSpan<Element> {
        let start: UnsafeMutablePointer<Element>
        switch _storage {
        case .inline(let arm):
            start = unsafe arm.pointer(at: .zero)
        case .heap(let arm):
            start = unsafe arm.pointer(at: .zero)
        }
        let span = unsafe Swift.MutableSpan(_unsafeStart: start, count: count)
        return unsafe _overrideLifetime(span, mutating: &self)
    }
}

// MARK: - Span.Protocol Conformance

extension Memory.Small: Span.`Protocol` where Element: ~Copyable {
    /// Unsafe read access for C interop with unannotated APIs.
    @inlinable
    public func withUnsafeBufferPointer<R, E: Swift.Error>(
        _ body: (UnsafeBufferPointer<Element>) throws(E) -> R
    ) throws(E) -> R {
        switch _storage {
        case .inline(let arm):
            return try unsafe body(
                UnsafeBufferPointer(start: arm.pointer(at: .zero), count: arm.initialization.count)
            )
        case .heap(let arm):
            return try unsafe body(
                UnsafeBufferPointer(start: arm.pointer(at: .zero), count: arm.initialization.count)
            )
        }
    }
}

// MARK: - Span.Mutable.Protocol Conformance

extension Memory.Small: Span.Mutable.`Protocol` where Element: ~Copyable {}
