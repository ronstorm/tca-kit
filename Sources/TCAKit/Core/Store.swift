//  Store.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation
import Combine

/// A store that manages state and handles actions using a reducer
///
/// The Store is the central component of the TCA architecture. It holds the current state,
/// processes actions through a reducer, and publishes state changes for UI observation.
///
/// - State: The type of state managed by this store (must be a struct)
/// - Action: The type of actions this store can handle (must be an enum)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor
public final class Store<State, Action>: ObservableObject {
    /// The current state of the store
    @Published public private(set) var state: State

    /// The reducer function that handles actions and updates state
    private let reducer: Reducer<State, Action>

    /// The dependencies available to the reducer
    private let dependencies: Dependencies

    /// A task that handles running effects
    private var effectTask: Task<Void, Never>?

    /// In-flight tasks keyed by cancellation id
    private var inflightTasksByID: [AnyHashable: Task<Void, Never>] = [:]

    /// Creates a new store with initial state and a reducer
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the store
    ///   - reducer: The reducer function that handles actions
    ///   - dependencies: The dependencies available to the reducer
    public init(
        initialState: State,
        reducer: @escaping Reducer<State, Action>,
        dependencies: Dependencies
    ) {
        self.state = initialState
        self.reducer = reducer
        self.dependencies = dependencies
    }

    /// Sends an action to the store for processing
    ///
    /// - Parameter action: The action to send
    public func send(_ action: Action) {
        let effect = reducer(&state, action, dependencies)

        // Handle cancellation request effects
        if effect.isCancellationRequest, let id = effect.cancellationId {
            inflightTasksByID[id]?.cancel()
            inflightTasksByID[id] = nil
            return
        }

        // If the effect is associated with a cancellation id and requires cancelling in-flight
        if let id = effect.cancellationId, effect.cancelInFlight {
            inflightTasksByID[id]?.cancel()
            inflightTasksByID[id] = nil
        }

        // Cancel previous single task behavior when no cancellation id is provided
        if effect.cancellationId == nil {
            effectTask?.cancel()
        }

        // Run the new effect
        let task = Task { [weak self] in
            guard let self = self else { return }

            if let nextAction = await effect.run() {
                await MainActor.run {
                    self.send(nextAction)
                }
            }

            // Cleanup when finished
            if let id = effect.cancellationId {
                // Clear the task from the dictionary when it completes
                self.inflightTasksByID[id] = nil
            }
        }

        if let id = effect.cancellationId {
            inflightTasksByID[id] = task
        } else {
            effectTask = task
        }
    }

    /// Creates a scoped store that only sees a portion of the parent state and actions
    ///
    /// - Parameters:
    ///   - toLocalState: A function that extracts local state from parent state
    ///   - fromLocalAction: A function that embeds local actions into parent actions
    /// - Returns: A new store scoped to the local state and actions
    public func scope<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action fromLocalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalState, LocalAction> {
        let localStore = Store<LocalState, LocalAction>(
            initialState: toLocalState(state),
            reducer: { localState, localAction, dependencies in
                // Update the parent state with the local state changes
                let parentAction = fromLocalAction(localAction)
                let effect = self.reducer(&self.state, parentAction, dependencies)

                // Update the local state to match the parent state
                localState = toLocalState(self.state)

                // Transform the effect to work with local actions
                return Effect<LocalAction> {
                    // Without an extractor, we drop parent actions
                    _ = await effect.run()
                    return nil
                }
            },
            dependencies: dependencies
        )

        // Observe parent state changes and update local state
        Task { [weak self, weak localStore] in
            guard let self = self, let localStore = localStore else { return }

            for await _ in self.$state.values {
                await MainActor.run {
                    localStore.state = toLocalState(self.state)
                }
            }
        }

        return localStore
    }

    /// Creates a scoped store that maps parent effects back into local actions using an extractor
    ///
    /// - Parameters:
    ///   - toLocalState: Extracts local state from parent state
    ///   - fromLocalAction: Embeds local actions into parent actions
    ///   - toLocalAction: Extracts local actions from parent actions (used to localize effect outputs)
    /// - Returns: A new store scoped to the local state and actions with effect localization
    public func scope<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action fromLocalAction: @escaping (LocalAction) -> Action,
        toLocalAction: @escaping (Action) -> LocalAction?
    ) -> Store<LocalState, LocalAction> {
        let localStore = Store<LocalState, LocalAction>(
            initialState: toLocalState(state),
            reducer: { localState, localAction, dependencies in
                let parentAction = fromLocalAction(localAction)
                let parentEffect = self.reducer(&self.state, parentAction, dependencies)

                // Sync local state with parent
                localState = toLocalState(self.state)

                // Map parent effect's output back to a local action while preserving cancellation metadata
                return Effect<LocalAction>(
                    operation: {
                        if let nextParent = await parentEffect.run(), let nextLocal = toLocalAction(nextParent) {
                            return nextLocal
                        }
                        return nil
                    },
                    cancellationId: parentEffect.cancellationId,
                    cancelInFlight: parentEffect.cancelInFlight,
                    isCancellationRequest: parentEffect.isCancellationRequest
                )
            },
            dependencies: dependencies
        )

        // Observe parent state changes and update local state
        Task { [weak self, weak localStore] in
            guard let self = self, let localStore = localStore else { return }

            for await _ in self.$state.values {
                await MainActor.run {
                    localStore.state = toLocalState(self.state)
                }
            }
        }

        return localStore
    }

    deinit {
        effectTask?.cancel()
        inflightTasksByID.values.forEach { $0.cancel() }
    }
}

// MARK: - Store Utilities

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension Store {
    /// Creates a store with a simple reducer that only updates state
    ///
    /// - Parameters:
    ///   - initialState: The initial state
    ///   - reduce: A closure that updates state based on actions
    ///   - dependencies: The dependencies available to the reducer
    /// - Returns: A store with the specified reducer
    public static func simple(
        initialState: State,
        reduce: @escaping (inout State, Action) -> Void,
        dependencies: Dependencies
    ) -> Store<State, Action> {
        return Store(
            initialState: initialState,
            reducer: { state, action, _ in
                reduce(&state, action)
                return .none
            },
            dependencies: dependencies
        )
    }
}
