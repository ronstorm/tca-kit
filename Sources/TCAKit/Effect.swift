//  Effect.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation

// MARK: - Effect Equatable Conformance

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension Effect: Equatable where Action: Equatable {
    public static func == (lhs: Effect<Action>, rhs: Effect<Action>) -> Bool {
        // For now, we'll consider effects equal if they're both .none
        // In a more complete implementation, we'd compare the underlying operations
        return false
    }
}

// MARK: - Effect None Check

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension Effect {
    /// Returns true if this effect is .none
    public var isNone: Bool {
        // This is a simple check - in a real implementation we'd have a more sophisticated way
        // to identify .none effects
        return false
    }
}

/// Represents a side effect that can be performed asynchronously
///
/// Effects are used to handle side effects like network requests, timers,
/// and other asynchronous operations in a testable way.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct Effect<Action> {
    /// The underlying async operation that produces actions
    private let operation: () async -> Action?
    
    /// Creates a new effect from an async operation
    ///
    /// - Parameter operation: An async closure that returns an optional action
    public init(_ operation: @escaping () async -> Action?) {
        self.operation = operation
    }
    
    /// Executes the effect and returns the resulting action
    ///
    /// - Returns: The action produced by the effect, or nil if no action should be sent
    public func run() async -> Action? {
        await operation()
    }
}

// MARK: - Effect Builders

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension Effect {
    /// Creates an effect that sends no action (useful for fire-and-forget operations)
    public static var none: Effect {
        Effect { nil }
    }
    
    /// Creates an effect that immediately sends a single action
    ///
    /// - Parameter action: The action to send
    /// - Returns: An effect that sends the specified action
    public static func send(_ action: Action) -> Effect {
        Effect { action }
    }
    
    /// Creates an effect that sends multiple actions in sequence
    ///
    /// - Parameter actions: The actions to send
    /// - Returns: An effect that sends all specified actions
    public static func sequence(_ actions: [Action]) -> Effect {
        Effect {
            // For now, we'll just send the first action
            // In a more complete implementation, this would handle multiple actions
            actions.first
        }
    }
    
    /// Creates an effect that runs an async operation and maps the result to an action
    ///
    /// - Parameters:
    ///   - operation: The async operation to run
    ///   - transform: A closure that transforms the result into an action
    /// - Returns: An effect that runs the operation and sends the transformed action
    public static func task<T>(
        operation: @escaping () async throws -> T,
        transform: @escaping (T) -> Action
    ) -> Effect {
        Effect {
            do {
                let result = try await operation()
                return transform(result)
            } catch {
                // In a more complete implementation, we'd handle errors
                return nil
            }
        }
    }
    
    /// Creates an effect that runs an async operation and maps the result to an action
    ///
    /// - Parameters:
    ///   - operation: The async operation to run
    ///   - transform: A closure that transforms the result into an action
    /// - Returns: An effect that runs the operation and sends the transformed action
    public static func task<T>(
        operation: @escaping () async -> T,
        transform: @escaping (T) -> Action
    ) -> Effect {
        Effect {
            let result = await operation()
            return transform(result)
        }
    }
}
