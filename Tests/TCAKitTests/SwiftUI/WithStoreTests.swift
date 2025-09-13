//  WithStoreTests.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Testing
import SwiftUI
@testable import TCAKit

// MARK: - WithStore Tests

struct WithStoreTests {

    @Test func testWithStoreBasicUsage() async throws {
        let dependencies = Dependencies()
        let store = await Store<CounterState, CounterAction>(
            initialState: CounterState(count: 5),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setCount(let newCount):
                    state.count = newCount
                }
                return .none
            },
            dependencies: dependencies
        )

        // Test that WithStore can be created
        _ = await WithStore(store) { store in
            Text("Count: \(store.state.count)")
        }

        // Verify the store is accessible
        #expect(await store.state.count == 5)
    }

    @Test func testWithStoreActionSending() async throws {
        let dependencies = Dependencies()
        let store = await Store<CounterState, CounterAction>(
            initialState: CounterState(count: 0),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setCount(let newCount):
                    state.count = newCount
                }
                return .none
            },
            dependencies: dependencies
        )

        _ = await WithStore(store) { store in
            VStack {
                Text("Count: \(store.state.count)")
                Button("Increment") {
                    store.send(.increment)
                }
            }
        }

        // Test that actions can be sent through the store
        await store.send(.increment)
        #expect(await store.state.count == 1)

        await store.send(.increment)
        #expect(await store.state.count == 2)

        await store.send(.reset)
        #expect(await store.state.count == 0)
    }

    @Test func testStoreWithStoreExtension() async throws {
        let dependencies = Dependencies()
        let store = await Store<CounterState, CounterAction>(
            initialState: CounterState(count: 7),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setCount(let newCount):
                    state.count = newCount
                }
                return .none
            },
            dependencies: dependencies
        )

        // Test the store.withStore extension
        _ = await store.withStore { store in
            VStack {
                Text("Count: \(store.state.count)")
                Button("Reset") {
                    store.send(.reset)
                }
            }
        }

        // Verify the store is accessible
        #expect(await store.state.count == 7)

        // Test action sending
        await store.send(.reset)
        #expect(await store.state.count == 0)
    }

    @Test func testWithStoreStateObservation() async throws {
        let dependencies = Dependencies()
        let store = await Store<CounterState, CounterAction>(
            initialState: CounterState(count: 0),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setCount(let newCount):
                    state.count = newCount
                }
                return .none
            },
            dependencies: dependencies
        )

        _ = await WithStore(store) { store in
            Text("Count: \(store.state.count)")
        }

        // Test multiple state changes
        await store.send(.increment)
        #expect(await store.state.count == 1)

        await store.send(.increment)
        #expect(await store.state.count == 2)

        await store.send(.decrement)
        #expect(await store.state.count == 1)

        await store.send(.reset)
        #expect(await store.state.count == 0)
    }

    @Test func testCounterExampleFunctionality() async throws {
        let dependencies = Dependencies()
        let store = await Store<CounterState, CounterAction>(
            initialState: CounterState(count: 0),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setCount(let newCount):
                    state.count = newCount
                }
                return .none
            },
            dependencies: dependencies
        )

        // Test the exact same flow as the BasicCounter example
        #expect(await store.state.count == 0)
        
        // Test increment (like tapping + button)
        await store.send(.increment)
        #expect(await store.state.count == 1)
        
        // Test increment again
        await store.send(.increment)
        #expect(await store.state.count == 2)
        
        // Test decrement (like tapping - button)
        await store.send(.decrement)
        #expect(await store.state.count == 1)
        
        // Test reset (like tapping Reset button)
        await store.send(.reset)
        #expect(await store.state.count == 0)
        
        // Test multiple increments
        await store.send(.increment)
        await store.send(.increment)
        await store.send(.increment)
        #expect(await store.state.count == 3)
        
        // Test reset again
        await store.send(.reset)
        #expect(await store.state.count == 0)
    }
}
