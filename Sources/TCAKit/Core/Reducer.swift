//  Reducer.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation

// Import types from other modules to ensure CI compatibility
// Note: In a single Swift module, these imports are technically not needed,
// but they help with clarity and ensure proper compilation across different environments

/// A function that handles actions and returns effects
///
/// Reducers are pure functions that describe how the current state should be updated
/// when an action is received, and what effects should be run as a result.
///
/// - Parameters:
///   - state: The current state (inout, will be modified)
///   - action: The action to handle
///   - dependencies: The dependencies available to the reducer
/// - Returns: An effect that can be run asynchronously
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public typealias Reducer<State, Action> = (inout State, Action, Dependencies) -> Effect<Action>

/// A namespace for reducer utilities and helpers
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum ReducerUtilities {
    /// Combines multiple reducers into a single reducer
    ///
    /// - Parameter reducers: The reducers to combine
    /// - Returns: A single reducer that runs all provided reducers in sequence
    public static func combine<State, Action>(
        _ reducers: Reducer<State, Action>...
    ) -> Reducer<State, Action> {
        return { state, action, dependencies in
            var combinedEffect: Effect<Action> = .none

            for reducer in reducers {
                let effect = reducer(&state, action, dependencies)
                // For now, we'll just return the last effect
                // In a more complete implementation, we'd combine effects properly
                combinedEffect = effect
            }

            return combinedEffect
        }
    }

    /// Creates a reducer that only handles specific actions
    ///
    /// - Parameters:
    ///   - action: The action type to handle
    ///   - reducer: The reducer to run for this action
    /// - Returns: A reducer that only runs for the specified action type
    public static func forAction<State, Action>(
        _ action: Action,
        reducer: @escaping (inout State, Action, Dependencies) -> Effect<Action>
    ) -> Reducer<State, Action> where Action: Equatable {
        return { state, receivedAction, dependencies in
            if receivedAction == action {
                return reducer(&state, receivedAction, dependencies)
            } else {
                return .none
            }
        }
    }

    /// Creates a reducer that transforms actions before passing them to another reducer
    ///
    /// - Parameters:
    ///   - transform: A closure that transforms the action
    ///   - reducer: The reducer to run with the transformed action
    /// - Returns: A reducer that transforms actions before processing
    public static func transform<State, Action, TransformedAction>(
        action transform: @escaping (Action) -> TransformedAction?,
        reducer: @escaping (inout State, TransformedAction, Dependencies) -> Effect<Action>
    ) -> Reducer<State, Action> {
        return { state, action, dependencies in
            guard let transformedAction = transform(action) else {
                return .none
            }
            return reducer(&state, transformedAction, dependencies)
        }
    }
}
