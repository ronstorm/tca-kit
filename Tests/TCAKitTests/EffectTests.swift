//  EffectTests.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Testing
import Foundation
@testable import TCAKit

// MARK: - Effect Tests

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@Test func testEffectNone() async throws {
    let effect = Effect<CounterAction>.none
    let result = await effect.run()
    #expect(result == nil)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@Test func testEffectSend() async throws {
    let effect = Effect<CounterAction>.send(.increment)
    let result = await effect.run()
    #expect(result == .increment)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@Test func testEffectSequence() async throws {
    let effect = Effect<CounterAction>.sequence([.increment, .decrement])
    let result = await effect.run()
    #expect(result == .increment) // Should return first action
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@Test func testEffectTask() async throws {
    let effect = Effect<CounterAction>.task(
        operation: {
            try await Task.sleep(nanoseconds: 1_000_000) // 1ms
            return 42
        },
        transform: { value in
            .setCount(value)
        }
    )

    let result = await effect.run()
    #expect(result == .setCount(42))
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@Test func testEffectTaskNonThrowing() async throws {
    let effect = Effect<CounterAction>.task(
        operation: {
            try await Task.sleep(nanoseconds: 1_000_000) // 1ms
            return 100
        },
        transform: { value in
            .setCount(value)
        }
    )

    let result = await effect.run()
    #expect(result == .setCount(100))
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@Test func testEffectTaskWithError() async throws {
    let effect = Effect<CounterAction>.task(
        operation: {
            throw NSError(domain: "TestError", code: 1, userInfo: [:])
        },
        transform: { value in
            .setCount(value)
        }
    )

    let result = await effect.run()
    #expect(result == nil) // Should return nil on error
}
