//  Dependencies.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation

/// A container for managing dependencies in a TCA-like environment
///
/// Dependencies provides a simple way to inject and manage dependencies throughout your app.
/// It follows the environment pattern used in The Composable Architecture, making it easy
/// to swap implementations for testing and different environments.
///
/// ## Usage
///
/// ```swift
/// // Create dependencies explicitly
/// let dependencies = Dependencies()
/// let store = Store(
///     initialState: AppState(),
///     reducer: appReducer,
///     dependencies: dependencies
/// )
///
/// // Override specific dependencies
/// let testDependencies = Dependencies.test
/// let store = Store(
///     initialState: AppState(),
///     reducer: appReducer,
///     dependencies: testDependencies
/// )
///
/// // In your reducer
/// func appReducer(state: inout AppState, action: AppAction, dependencies: Dependencies) -> Effect<AppAction> {
///     let currentDate = dependencies.date()
///     let newUUID = dependencies.uuid()
///     // ...
/// }
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct Dependencies {

    /// Provides the current date
    public var date: () -> Date = { Date() }

    /// Generates a new UUID
    public var uuid: () -> UUID = { UUID() }

    /// Performs HTTP requests
    public var httpClient: (URL) async throws -> Data = { url in
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    /// Creates a new Dependencies instance with default implementations
    public init() {}

    /// Creates a new Dependencies instance with custom implementations
    ///
    /// - Parameters:
    ///   - date: Custom date provider
    ///   - uuid: Custom UUID provider
    ///   - httpClient: Custom HTTP client
    public init(
        date: @escaping () -> Date = { Date() },
        uuid: @escaping () -> UUID = { UUID() },
        httpClient: @escaping (URL) async throws -> Data = { url in
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
    ) {
        self.date = date
        self.uuid = uuid
        self.httpClient = httpClient
    }

    /// Creates a copy of this Dependencies instance with a modified dependency
    ///
    /// - Parameters:
    ///   - keyPath: The key path to the dependency to modify
    ///   - value: The new value for the dependency
    /// - Returns: A new Dependencies instance with the modified dependency
    public func with<T>(_ keyPath: WritableKeyPath<Dependencies, T>, _ value: T) -> Dependencies {
        var dependencies = self
        dependencies[keyPath: keyPath] = value
        return dependencies
    }
}

// MARK: - Test Dependencies

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension Dependencies {
    /// Creates a test environment with predictable values
    ///
    /// - Returns: A Dependencies instance configured for testing
    public static var test: Dependencies {
        Dependencies(
            date: { Date(timeIntervalSince1970: 0) },
            uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! },
            httpClient: { _ in Data("test data".utf8) }
        )
    }

    /// Creates a mock environment with custom implementations
    ///
    /// - Parameters:
    ///   - date: Custom date provider
    ///   - uuid: Custom UUID provider
    ///   - httpClient: Custom HTTP client
    /// - Returns: A Dependencies instance with the specified implementations
    public static func mock(
        date: @escaping () -> Date = { Date(timeIntervalSince1970: 0) },
        uuid: @escaping () -> UUID = { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! },
        httpClient: @escaping (URL) async throws -> Data = { _ in Data("mock data".utf8) }
    ) -> Dependencies {
        Dependencies(
            date: date,
            uuid: uuid,
            httpClient: httpClient
        )
    }
}
