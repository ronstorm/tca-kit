//  ReducerTests.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Testing
@testable import TCAKit

// MARK: - Reducer Tests

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@Test func testReducerCombine() async throws {
    let reducer1: Reducer<CounterState, CounterAction> = { state, action, _ in
        switch action {
        case .increment:
            state.count += 1
        default:
            break
        }
        return .none
    }

    let reducer2: Reducer<CounterState, CounterAction> = { state, action, _ in
        switch action {
        case .increment:
            state.count += 1 // Double increment
        default:
            break
        }
        return .none
    }

    let combinedReducer = ReducerUtilities.combine(reducer1, reducer2)

    var state = CounterState(count: 0)
    let dependencies = Dependencies()
    _ = combinedReducer(&state, .increment, dependencies)

    #expect(state.count == 2) // Both reducers should run
    // Note: Effect equality is not implemented in this simple version
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@Test func testReducerForAction() async throws {
    let reducer: Reducer<CounterState, CounterAction> = { state, action, _ in
        switch action {
        case .increment:
            state.count += 1
            return .send(.decrement) // Return an effect
        default:
            break
        }
        return .none
    }

    let specificReducer = ReducerUtilities.forAction(.increment, reducer: reducer)

    var state = CounterState(count: 0)
    let dependencies = Dependencies()

    // Test matching action
    _ = specificReducer(&state, .increment, dependencies)
    #expect(state.count == 1)
    // Note: Effect equality is not implemented in this simple version

    // Test non-matching action
    _ = specificReducer(&state, .decrement, dependencies)
    #expect(state.count == 1) // Should not change
    // Note: Effect equality is not implemented in this simple version
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@Test func testReducerTransform() async throws {
    enum StringAction {
        case setText(String)
    }

    let _: Reducer<CounterState, StringAction> = { state, action, _ in
        switch action {
        case .setText(let text):
            state.count = text.count
        }
        return .none
    }

    let transformedReducer: Reducer<CounterState, CounterAction> = ReducerUtilities.transform(
        action: { (action: CounterAction) -> StringAction? in
            switch action {
            case .setCount(let count):
                return .setText("\(count)")
            default:
                return nil
            }
        },
        reducer: { (state: inout CounterState, action: StringAction, _: Dependencies)
            -> Effect<CounterAction> in
            switch action {
            case .setText(let text):
                state.count = text.count
            }
            return .none
        }
    )

    var state = CounterState(count: 0)
    let dependencies = Dependencies()

    // Test transformable action
    _ = transformedReducer(&state, CounterAction.setCount(42), dependencies)
    #expect(state.count == 2) // "42" has 2 characters
    // Note: Effect equality is not implemented in this simple version

    // Test non-transformable action
    _ = transformedReducer(&state, CounterAction.increment, dependencies)
    #expect(state.count == 2) // Should not change
    // Note: Effect equality is not implemented in this simple version
}
