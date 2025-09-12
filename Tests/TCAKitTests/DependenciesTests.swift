//  DependenciesTests.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Testing
import Foundation
@testable import TCAKit

struct DependenciesTests {

    @Test func testDefaultDependencies() async throws {
        let dependencies = Dependencies()

        // Test that default dependencies are functional
        let date = dependencies.date()
        #expect(date.timeIntervalSince1970 > 0)

        let uuid = dependencies.uuid()
        #expect(uuid.uuidString.count == 36) // Standard UUID format
    }

    @Test func testTestDependencies() async throws {
        let testDeps = Dependencies.test

        // Test that test dependencies return predictable values
        let date = testDeps.date()
        #expect(date.timeIntervalSince1970 == 0)

        let uuid = testDeps.uuid()
        #expect(uuid.uuidString == "00000000-0000-0000-0000-000000000000")
    }

    @Test func testMockDependencies() async throws {
        let fixedDate = Date(timeIntervalSince1970: 1234567890)
        let fixedUUID = UUID(uuidString: "12345678-1234-1234-1234-123456789012")!

        let mockDeps = Dependencies.mock(
            date: { fixedDate },
            uuid: { fixedUUID }
        )

        #expect(mockDeps.date() == fixedDate)
        #expect(mockDeps.uuid() == fixedUUID)
    }

    @Test func testDependenciesWithModification() async throws {
        let originalDeps = Dependencies()
        let fixedDate = Date(timeIntervalSince1970: 0)

        let modifiedDeps = originalDeps.with(\.date, { fixedDate })

        #expect(modifiedDeps.date() == fixedDate)
        #expect(modifiedDeps.uuid() != originalDeps.uuid()) // Should still generate new UUIDs
    }

    @Test func testDependenciesCreation() async throws {
        // Test that dependencies can be created explicitly
        let deps = Dependencies()

        let date = deps.date()
        let uuid = deps.uuid()

        #expect(date.timeIntervalSince1970 > 0)
        #expect(uuid.uuidString.count == 36)
    }

    @Test func testDependenciesImmutability() async throws {
        let deps1 = Dependencies()
        let deps2 = deps1.with(\.date, { Date(timeIntervalSince1970: 0) })

        // Original should be unchanged
        #expect(deps1.date().timeIntervalSince1970 > 0)

        // Modified should have new value
        #expect(deps2.date().timeIntervalSince1970 == 0)
    }

    @Test func testDependenciesInStore() async throws {
        // Test using dependencies in a store
        struct TestState {
            var currentDate: Date?
            var currentUUID: UUID?
        }

        enum TestAction {
            case getCurrentDate
            case getCurrentUUID
        }

        let testReducer: Reducer<TestState, TestAction> = { state, action, dependencies in
            switch action {
            case .getCurrentDate:
                state.currentDate = dependencies.date()
                return .none
            case .getCurrentUUID:
                state.currentUUID = dependencies.uuid()
                return .none
            }
        }

        let testDeps = Dependencies.test
        let store = await Store(
            initialState: TestState(),
            reducer: testReducer,
            dependencies: testDeps
        )

        await store.send(.getCurrentDate)
        await store.send(.getCurrentUUID)

        #expect(await store.state.currentDate == Date(timeIntervalSince1970: 0))
        #expect(await store.state.currentUUID == UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
    }
}
