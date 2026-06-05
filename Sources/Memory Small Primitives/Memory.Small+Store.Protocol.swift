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
public import Store_Initialization_Primitives
public import Store_Protocol_Primitives
public import Store_Tracked_Primitives

// MARK: - The per-slot seam (delegates to the active arm; both arms are seam-proven leaves)
//
// The mutable projection over a ~Copyable ENUM payload uses the active arm's `pointer(at:)`
// escape hatch; `initialize`/`move`/`initialization`-set go through the full-reassignment idiom
// (`self = Self(_storage:)`).

extension Memory.Small where Element: ~Copyable {
    @inlinable
    public subscript(slot: Index<Element>) -> Element {
        _read {
            switch _storage {
            case .inline(let arm):
                let pointer: UnsafeMutablePointer<Element> = unsafe arm.pointer(at: slot)
                yield unsafe pointer.pointee
            case .heap(let arm):
                let pointer: UnsafeMutablePointer<Element> = unsafe arm.pointer(at: slot)
                yield unsafe pointer.pointee
            }
        }
        _modify {
            switch _storage {
            case .inline(let arm):
                let pointer: UnsafeMutablePointer<Element> = unsafe arm.pointer(at: slot)
                yield &(unsafe pointer.pointee)
            case .heap(let arm):
                let pointer: UnsafeMutablePointer<Element> = unsafe arm.pointer(at: slot)
                yield &(unsafe pointer.pointee)
            }
        }
    }

    @inlinable
    public mutating func initialize(at slot: Index<Element>, to element: consuming Element) {
        switch _storage {
        case .inline(var arm):
            arm.initialize(at: slot, to: consume element)
            self = Self(_storage: .inline(consume arm))
        case .heap(var arm):
            arm.initialize(at: slot, to: consume element)
            self = Self(_storage: .heap(consume arm))
        }
    }

    @inlinable
    public mutating func move(at slot: Index<Element>) -> Element {
        switch _storage {
        case .inline(var arm):
            let element = arm.move(at: slot)
            self = Self(_storage: .inline(consume arm))
            return element
        case .heap(var arm):
            let element = arm.move(at: slot)
            self = Self(_storage: .heap(consume arm))
            return element
        }
    }

    /// The initialization ledger — delegates to the active arm.
    @inlinable
    public var initialization: Store.Initialization<Element> {
        get {
            switch _storage {
            case .inline(let arm): arm.initialization
            case .heap(let arm): arm.initialization
            }
        }
        set {
            switch _storage {
            case .inline(var arm):
                arm.initialization = newValue
                self = Self(_storage: .inline(consume arm))
            case .heap(var arm):
                arm.initialization = newValue
                self = Self(_storage: .heap(consume arm))
            }
        }
    }
}

// MARK: - Store.Protocol + Store.Tracked.Protocol conformances (NOT Storage.Protocol — this is a leaf)

extension Memory.Small: Store.`Protocol` where Element: ~Copyable {}
extension Memory.Small: Store.Tracked.`Protocol` where Element: ~Copyable {}
