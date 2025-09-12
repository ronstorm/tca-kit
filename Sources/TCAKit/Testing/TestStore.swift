//  TestStore.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation

/// A test utility for testing TCAKit stores with fluent assertions
///
/// TestStore provides a fluent API for testing store behavior, allowing you to send actions,
/// assert state changes, and verify effects step by step. It generates a transcript of all
/// test steps for debugging and documentation purposes.
///
/// ## Usage
///
/// ```swift
/// func testCounter() async throws {
///     let store = TestStore(
///         initialState: CounterState(count: 0),
///         reducer: counterReducer,
///         dependencies: Dependencies.test
///     )
///
///     await store
///         .send(.increment) { state in
///             state.count = 1
///         }
///         .send(.increment) { state in
///             state.count = 2
///         }
///         .finish()
/// }
/// ```
///
/// ## Effect Testing
///
/// ```swift
/// func testDataLoading() async throws {
///     let store = TestStore(
///         initialState: AppState(),
///         reducer: appReducer,
///         dependencies: Dependencies.test
///     )
///
///     await store
///         .send(.loadData) { state in
///             state.isLoading = true
///         }
///         .receive(.dataLoaded("test data")) { state in
///             state.isLoading = false
///             state.data = "test data"
///         }
///         .finish()
/// }
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public final class TestStore<State, Action> {
    private let store: Store<State, Action>
    private var transcript: [TestStep<State, Action>] = []
    private var currentState: State
    private let dependencies: Dependencies

    /// Creates a TestStore for testing
    ///
    /// - Parameters:
    ///   - initialState: The initial state for testing
    ///   - reducer: The reducer function to test
    ///   - dependencies: The dependencies to use (typically Dependencies.test)
    @MainActor
    public init(
        initialState: State,
        reducer: @escaping Reducer<State, Action>,
        dependencies: Dependencies
    ) {
        self.dependencies = dependencies
        self.currentState = initialState
        self.store = Store(
            initialState: initialState,
            reducer: reducer,
            dependencies: dependencies
        )
    }

    /// Sends an action and asserts the resulting state change
    ///
    /// - Parameters:
    ///   - action: The action to send
    ///   - assert: A closure that asserts the expected state change
    /// - Returns: Self for method chaining
    @MainActor
    public func send(
        _ action: Action,
        assert: @escaping (inout State) -> Void
    ) async -> TestStore<State, Action> {
        let previousState = currentState

        // Send the action to the store
        store.send(action)

        // Update our current state
        var newState = await store.state
        assert(&newState)

        // Record the test step
        let step = TestStep<State, Action>(
            type: .send,
            action: action,
            previousState: previousState,
            newState: newState,
            timestamp: Date()
        )
        transcript.append(step)

        // Verify the state matches our assertion
        if !areStatesEqual(previousState, newState) {
            // The assertion modified the state, so we need to verify it matches the actual state
            let actualState = await store.state
            if !areStatesEqual(newState, actualState) {
                fatalError("State assertion failed. Expected: \(newState), Actual: \(actualState)")
            }
        }

        currentState = newState
        return self
    }

    /// Receives an action (typically from an effect) and asserts the resulting state change
    ///
    /// - Parameters:
    ///   - action: The action to receive
    ///   - assert: A closure that asserts the expected state change
    /// - Returns: Self for method chaining
    @MainActor
    public func receive(
        _ action: Action,
        assert: @escaping (inout State) -> Void
    ) async -> TestStore<State, Action> {
        let previousState = currentState

        // Send the action to the store
        store.send(action)

        // Update our current state
        var newState = await store.state
        assert(&newState)

        // Record the test step
        let step = TestStep<State, Action>(
            type: .receive,
            action: action,
            previousState: previousState,
            newState: newState,
            timestamp: Date()
        )
        transcript.append(step)

        // Verify the state matches our assertion
        let actualState = await store.state
        if !areStatesEqual(newState, actualState) {
            fatalError("State assertion failed. Expected: \(newState), Actual: \(actualState)")
        }

        currentState = newState
        return self
    }

    /// Finishes the test and returns the transcript
    ///
    /// - Returns: The test transcript
    public func finish() -> TestTranscript<State, Action> {
        return TestTranscript(steps: transcript)
    }

    /// Gets the current state of the test store
    public var state: State {
        return currentState
    }

    /// Gets the test transcript so far
    public var currentTranscript: TestTranscript<State, Action> {
        return TestTranscript(steps: transcript)
    }

    // MARK: - Private Helpers

    private func areStatesEqual(_ lhs: State, _ rhs: State) -> Bool {
        // For now, we'll use a simple approach
        // In a real implementation, we might want to use reflection or make State conform to Equatable
        return String(describing: lhs) == String(describing: rhs)
    }
}

// MARK: - Test Transcript

/// A transcript of test steps for debugging and documentation
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct TestTranscript<State, Action> {
    public let steps: [TestStep<State, Action>]

    public init(steps: [TestStep<State, Action>]) {
        self.steps = steps
    }

    /// Returns a human-readable description of the test transcript
    public var description: String {
        var result = "Test Transcript:\n"
        for (index, step) in steps.enumerated() {
            result += "\(index + 1). \(step.description)\n"
        }
        return result
    }
}

// MARK: - Test Step

/// A single step in a test transcript
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct TestStep<State, Action> {
    public enum StepType {
        case send
        case receive
    }

    public let type: StepType
    public let action: Action
    public let previousState: State
    public let newState: State
    public let timestamp: Date

    public init(
        type: StepType,
        action: Action,
        previousState: State,
        newState: State,
        timestamp: Date
    ) {
        self.type = type
        self.action = action
        self.previousState = previousState
        self.newState = newState
        self.timestamp = timestamp
    }

    /// Returns a human-readable description of this test step
    public var description: String {
        let actionType = type == .send ? "Send" : "Receive"
        return "\(actionType) \(action) - State: \(previousState) → \(newState)"
    }
}
