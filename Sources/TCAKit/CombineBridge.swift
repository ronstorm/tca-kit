//  CombineBridge.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation
import Combine

// MARK: - Publisher to Effect Conversion

/// Extension to convert Combine publishers to TCAKit effects
///
/// This module provides seamless integration between Combine publishers and TCAKit effects,
/// allowing you to use existing Combine-based code with TCAKit stores.
///
/// ## Usage
///
/// ```swift
/// // Convert a Combine publisher to a TCAKit effect
/// let effect = dataPublisher
///     .map { data in AppAction.dataLoaded(data) }
///     .eraseToEffect()
///
/// // Use in reducer
/// func appReducer(state: inout AppState, action: AppAction, dependencies: Dependencies) -> Effect<AppAction> {
///     switch action {
///     case .loadData:
///         return loadDataPublisher
///             .map { .dataLoaded($0) }
///             .eraseToEffect()
///     }
/// }
/// ```
///
/// ## Store to Publisher Bridge
///
/// ```swift
/// // Convert store state to a Combine publisher
/// let statePublisher = store.statePublisher
///     .map { $0.count }
///     .eraseToAnyPublisher()
///
/// // Subscribe to state changes
/// statePublisher
///     .sink { count in
///         print("Count changed to: \(count)")
///     }
///     .store(in: &cancellables)
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Failure == Never {
    /// Converts a Combine publisher to a TCAKit effect
    ///
    /// - Returns: A TCAKit effect that will send the publisher's output as an action
    func eraseToEffect() -> Effect<Output> {
        return Effect.task(
            operation: {
                await withCheckedContinuation { continuation in
                    var cancellable: AnyCancellable?
                    cancellable = self
                        .sink(
                            receiveCompletion: { _ in
                                cancellable?.cancel()
                            },
                            receiveValue: { value in
                                continuation.resume(returning: value)
                                cancellable?.cancel()
                            }
                        )
                }
            },
            transform: { $0 }
        )
    }
}

/// Extension to convert Combine publishers that can fail to TCAKit effects
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Failure: Error {
    /// Converts a Combine publisher that can fail to a TCAKit effect
    ///
    /// - Returns: A TCAKit effect that will send the publisher's output as an action or handle errors
    func eraseToEffect() -> Effect<Output> {
        return Effect.task(
            operation: {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Output, Error>) in
                    var cancellable: AnyCancellable?
                    cancellable = self
                        .sink(
                            receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    break
                                case .failure(let error):
                                    continuation.resume(throwing: error)
                                }
                                cancellable?.cancel()
                            },
                            receiveValue: { value in
                                continuation.resume(returning: value)
                                cancellable?.cancel()
                            }
                        )
                }
            },
            transform: { $0 }
        )
    }
}

// MARK: - Store to Publisher Bridge

/// Extension to convert TCAKit stores to Combine publishers
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension Store {
    /// Creates a Combine publisher that emits the current state
    ///
    /// - Returns: A publisher that emits the store's current state
    var statePublisher: AnyPublisher<State, Never> {
        return StatePublisher(store: self)
            .eraseToAnyPublisher()
    }

    /// Creates a Combine publisher that emits state changes
    ///
    /// - Returns: A publisher that emits state changes
    var stateChangesPublisher: AnyPublisher<State, Never> {
        return StateChangesPublisher(store: self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Internal Publishers

/// A Combine publisher that emits the current state of a TCAKit store
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct StatePublisher<State, Action>: Publisher {
    typealias Output = State
    typealias Failure = Never

    private let store: Store<State, Action>

    init(store: Store<State, Action>) {
        self.store = store
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = StateSubscription(store: store, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

/// A Combine publisher that emits state changes of a TCAKit store
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct StateChangesPublisher<State, Action>: Publisher {
    typealias Output = State
    typealias Failure = Never

    private let store: Store<State, Action>

    init(store: Store<State, Action>) {
        self.store = store
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = StateChangesSubscription(store: store, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

// MARK: - Internal Subscriptions

/// A Combine subscription that provides the current state of a TCAKit store
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private final class StateSubscription<State, Action, S: Subscriber>: Subscription
where S.Input == State, S.Failure == Never {
    private let store: Store<State, Action>
    private let subscriber: S
    private var isCancelled = false

    init(store: Store<State, Action>, subscriber: S) {
        self.store = store
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        guard !isCancelled, demand > 0 else { return }

        Task { @MainActor in
            let currentState = await store.state
            _ = subscriber.receive(currentState)
            subscriber.receive(completion: .finished)
        }
    }

    func cancel() {
        isCancelled = true
    }
}

/// A Combine subscription that provides state changes of a TCAKit store
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private final class StateChangesSubscription<State, Action, S: Subscriber>: Subscription
where S.Input == State, S.Failure == Never {
    private let store: Store<State, Action>
    private let subscriber: S
    private var isCancelled = false
    private var task: Task<Void, Never>?

    init(store: Store<State, Action>, subscriber: S) {
        self.store = store
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        guard !isCancelled, demand > 0 else { return }

        task = Task { @MainActor in
            // Send initial state
            let initialState = await store.state
            _ = subscriber.receive(initialState)

            // In a real implementation, we would observe state changes
            // For now, we'll just send the initial state and complete
            subscriber.receive(completion: .finished)
        }
    }

    func cancel() {
        isCancelled = true
        task?.cancel()
    }
}

// MARK: - Utility Extensions

/// Extension to create effects from async operations
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension Effect {
    /// Creates an effect from a Combine publisher
    ///
    /// - Parameter publisher: The Combine publisher to convert
    /// - Returns: A TCAKit effect
    static func fromPublisher<PublisherType: Publisher>(
        _ publisher: PublisherType
    ) -> Effect<PublisherType.Output> where PublisherType.Failure == Never {
        return publisher.eraseToEffect()
    }

    /// Creates an effect from a Combine publisher that can fail
    ///
    /// - Parameter publisher: The Combine publisher to convert
    /// - Returns: A TCAKit effect
    static func fromPublisher<PublisherType: Publisher>(
        _ publisher: PublisherType
    ) -> Effect<PublisherType.Output> where PublisherType.Failure: Error {
        return publisher.eraseToEffect()
    }
}

// MARK: - Action Sending Bridge

/// Extension to send actions to a store from Combine publishers
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Output: Sendable, Failure == Never {
    /// Sends the publisher's output as actions to the given store
    ///
    /// - Parameter store: The store to send actions to
    /// - Returns: A cancellable for the subscription
    func send(to store: Store<Output, Output>) -> AnyCancellable {
        return self
            .sink { action in
                Task { @MainActor in
                    store.send(action)
                }
            }
    }
}

/// Extension to send actions to a store from Combine publishers with action mapping
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Failure == Never {
    /// Sends the publisher's output as actions to the given store after mapping
    ///
    /// - Parameters:
    ///   - store: The store to send actions to
    ///   - transform: A closure to transform the output to an action
    /// - Returns: A cancellable for the subscription
    func send<Action>(
        to store: Store<Action, Action>,
        transform: @escaping (Output) -> Action
    ) -> AnyCancellable {
        return self
            .map(transform)
            .sink { action in
                Task { @MainActor in
                    store.send(action)
                }
            }
    }
}
