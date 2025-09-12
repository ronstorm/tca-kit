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
    
    /// A task that handles running effects
    private var effectTask: Task<Void, Never>?
    
    /// Creates a new store with initial state and a reducer
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the store
    ///   - reducer: The reducer function that handles actions
    public init(
        initialState: State,
        reducer: @escaping Reducer<State, Action>
    ) {
        self.state = initialState
        self.reducer = reducer
    }
    
    /// Sends an action to the store for processing
    ///
    /// - Parameter action: The action to send
    public func send(_ action: Action) {
        let effect = reducer(&state, action)
        
        // Cancel any existing effect task
        effectTask?.cancel()
        
        // Run the new effect
        effectTask = Task { [weak self] in
            guard let self = self else { return }
            
            if let nextAction = await effect.run() {
                await MainActor.run {
                    self.send(nextAction)
                }
            }
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
            reducer: { localState, localAction in
                // Update the parent state with the local state changes
                let parentAction = fromLocalAction(localAction)
                let effect = self.reducer(&self.state, parentAction)
                
                // Update the local state to match the parent state
                localState = toLocalState(self.state)
                
                // Transform the effect to work with local actions
                return Effect<LocalAction> {
                    if await effect.run() != nil {
                        // For now, we'll just return nil for scoped effects
                        // In a more complete implementation, we'd handle action transformation
                        return nil
                    }
                    return nil
                }
            }
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
    /// - Returns: A store with the specified reducer
    public static func simple(
        initialState: State,
        reduce: @escaping (inout State, Action) -> Void
    ) -> Store<State, Action> {
        return Store(
            initialState: initialState,
            reducer: { state, action in
                reduce(&state, action)
                return .none
            }
        )
    }
}
