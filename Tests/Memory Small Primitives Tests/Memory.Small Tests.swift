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

import Testing

@testable import Memory_Small_Primitives

// The suite extends the top-level `Memory` namespace rather than `Memory.Small`: the source type is
// value-generic (`Memory.Small<let inlineCapacity: Int>`), and the `@Suite` macro expands to static
// stored properties, which Swift forbids inside a generic type ("static stored properties not
// supported in generic types"). `Memory` is the non-generic top-level domain namespace, so it hosts
// the suite while the smoke test still references `Memory.Small` from this module.

extension Memory {
    @Suite struct Tests {
        @Test func `namespace is available`() {
            // Minimal smoke test — the real suite is authored during flip-prep.
            _ = Memory.Small<8>.self
            #expect(Bool(true))
        }
    }
}
