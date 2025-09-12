//  TCAKit.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation

/// TCAKit - A lightweight toolkit for The Composable Architecture
///
/// TCAKit provides a simple, SwiftUI-first implementation of TCA patterns with
/// one-way data flow, reducers, and effects. It's designed to be easy to drop
/// into SwiftUI apps with low boilerplate and async/await support.
///
/// ## Core Components
///
/// - **Store**: Manages state and handles actions with @MainActor publishing
/// - **Reducer**: Pure functions that handle actions and return effects
/// - **Effect**: Represents async side effects with cancellation support
/// - **Dependencies**: Environment-based dependency injection for services
///
/// ## Usage
///
/// ```swift
/// import TCAKit
///
/// struct AppState {
///     var count: Int = 0
/// }
///
/// enum AppAction {
///     case increment
///     case decrement
/// }
///
/// let dependencies = Dependencies()
/// let store = Store(
///     initialState: AppState(),
///     reducer: { state, action, dependencies in
///         switch action {
///         case .increment:
///             state.count += 1
///         case .decrement:
///             state.count -= 1
///         }
///         return .none
///     },
///     dependencies: dependencies
/// )
///
/// // In SwiftUI
/// struct ContentView: View {
///     @StateObject private var store = store
///
///     var body: some View {
///         VStack {
///             Text("Count: \(store.state.count)")
///             Button("Increment") {
///                 store.send(.increment)
///             }
///         }
///     }
/// }
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct TCAKit {
    /// The current version of TCAKit
    public static let version = "1.0.0"

    /// Initialize TCAKit
    public init() {}
}

// MARK: - Public API

/// A collection of TCA utilities and extensions
public enum TCAUtilities {
    /// Common TCA patterns and utilities
    public enum Patterns {
        // Future pattern implementations will go here
    }

    /// TCA extensions and helpers
    public enum Extensions {
        // Future extension implementations will go here
    }
}
