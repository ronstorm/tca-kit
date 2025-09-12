//  WithStore.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import SwiftUI

/// A SwiftUI view that provides a store to its content
///
/// WithStore is a SwiftUI helper that makes it easy to use TCAKit stores in views.
/// It automatically handles store observation and provides the store to its content closure.
///
/// ## Usage
///
/// ```swift
/// struct CounterView: View {
///     let store: Store<CounterState, CounterAction>
///
///     var body: some View {
///         WithStore(store) { store in
///             VStack {
///                 Text("Count: \(store.state.count)")
///                 Button("Increment") {
///                     store.send(.increment)
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// ## Scoped Stores
///
/// WithStore works seamlessly with scoped stores:
///
/// ```swift
/// WithStore(store.scope(state: \.counter, action: AppAction.counter)) { counterStore in
///     CounterView(store: counterStore)
/// }
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct WithStore<State, Action, Content: View>: View {
    private let store: Store<State, Action>
    private let content: (Store<State, Action>) -> Content

    /// Creates a WithStore view
    ///
    /// - Parameters:
    ///   - store: The store to provide to the content
    ///   - content: A view builder that receives the store
    @MainActor
    public init(
        _ store: Store<State, Action>,
        @ViewBuilder content: @escaping @MainActor (Store<State, Action>) -> Content
    ) {
        self.store = store
        self.content = content
    }

    @MainActor
    public var body: some View {
        content(store)
    }
}

// MARK: - Convenience Extensions

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension WithStore {
    /// Creates a WithStore view with a scoped store
    ///
    /// - Parameters:
    ///   - store: The parent store to scope from
    ///   - toLocalState: A function that extracts local state from parent state
    ///   - fromLocalAction: A function that embeds local actions into parent actions
    ///   - content: A view builder that receives the scoped store
    public init<LocalState, LocalAction>(
        _ store: Store<State, Action>,
        state toLocalState: @escaping (State) -> LocalState,
        action fromLocalAction: @escaping (LocalAction) -> Action,
        @ViewBuilder content: @escaping (Store<LocalState, LocalAction>) -> Content
    ) where Content == AnyView {
        let scopedStore = store.scope(
            state: toLocalState,
            action: fromLocalAction
        )
        self.store = scopedStore as? Store<State, Action> ?? store
        self.content = { _ in AnyView(content(scopedStore)) }
    }
}

// MARK: - Store Extensions

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension Store {
    /// Creates a WithStore view with this store
    ///
    /// - Parameter content: A view builder that receives this store
    /// - Returns: A WithStore view containing the provided content
    @MainActor
    public func withStore<Content: View>(
        @ViewBuilder content: @escaping @MainActor (Store<State, Action>) -> Content
    ) -> WithStore<State, Action, Content> {
        WithStore(self, content: content)
    }
}
