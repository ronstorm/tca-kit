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

    // MARK: Cancellation metadata

    /// Optional identifier used by the Store to manage cancellation of in-flight effects
    /// If set, the Store may cancel an existing task with the same identifier before starting this one
    let cancellationId: AnyHashable?

    /// Whether a previous in-flight effect with the same `cancellationId` should be cancelled
    /// before starting this effect
    let cancelInFlight: Bool

    /// If true, this effect represents a cancellation request for the provided `cancellationId`
    /// The Store will cancel the task (if any) and not run this effect's operation
    let isCancellationRequest: Bool

    /// Creates a new effect from an async operation
    ///
    /// - Parameter operation: An async closure that returns an optional action
    public init(_ operation: @escaping () async -> Action?) {
        self.operation = operation
        self.cancellationId = nil
        self.cancelInFlight = false
        self.isCancellationRequest = false
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

    // MARK: - Cancellation helpers

    /// Marks this effect as cancellable by the given identifier.
    /// If `cancelInFlight` is true, the store will cancel any in-flight effect with the same id
    /// before starting this one.
    /// - Parameters:
    ///   - id: A hashable identifier for this effect.
    ///   - cancelInFlight: Whether to cancel an in-flight effect with the same id.
    /// - Returns: A new effect carrying the cancellation metadata.
    public func cancellable(id: AnyHashable, cancelInFlight: Bool = false) -> Effect {
        var effect = self
        // Rebuild effect to preserve operation but attach metadata
        effect = Effect(effect.operation)
        effect = effect.attachCancellation(id: id, cancelInFlight: cancelInFlight)
        return effect
    }

    /// Creates an effect that represents a cancellation request for an in-flight effect with the given identifier.
    /// - Parameter id: The identifier of the effect to cancel.
    /// - Returns: An effect that will instruct the store to cancel the in-flight effect.
    public static func cancel(id: AnyHashable) -> Effect {
        var effect = Effect { nil }
        effect = effect.asCancellationRequest(id: id)
        return effect
    }
}

// MARK: - Internal helpers (for Store integration)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension Effect {
    /// Internal initializer for attaching cancellation metadata.
    /// Not public API; used by the Store.
    init(
        operation: @escaping () async -> Action?,
        cancellationId: AnyHashable?,
        cancelInFlight: Bool,
        isCancellationRequest: Bool
    ) {
        self.operation = operation
        self.cancellationId = cancellationId
        self.cancelInFlight = cancelInFlight
        self.isCancellationRequest = isCancellationRequest
    }

    /// Attaches cancellation metadata to an effect.
    func attachCancellation(id: AnyHashable, cancelInFlight: Bool) -> Effect {
        Effect(
            operation: self.operation,
            cancellationId: id,
            cancelInFlight: cancelInFlight,
            isCancellationRequest: false
        )
    }

    /// Converts this effect into a cancellation request for the given id.
    func asCancellationRequest(id: AnyHashable) -> Effect {
        Effect(
            operation: self.operation,
            cancellationId: id,
            cancelInFlight: true,
            isCancellationRequest: true
        )
    }
}
