//  TCAKitTests.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Testing
@testable import TCAKit

@Test func testTCAKitVersion() async throws {
    // Test that TCAKit version is properly set
    #expect(TCAKit.version == "1.0.0")
}

@Test func testTCAKitInitialization() async throws {
    // Test that TCAKit can be initialized
    _ = TCAKit()
    #expect(TCAKit.version == "1.0.0")
}

@Test func testTCAUtilitiesStructure() async throws {
    // Test that TCAUtilities structure is accessible
    _ = TCAUtilities.Patterns.self
    _ = TCAUtilities.Extensions.self
}
