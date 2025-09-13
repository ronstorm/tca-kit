//  Models.swift
//  TCAKit Examples
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation
import TCAKit

// MARK: - Todo Model

/// Represents a single todo item
public struct Todo: Identifiable, Equatable, Codable {
    public let id: UUID
    var text: String
    var isCompleted: Bool
    let createdAt: Date
    
    init(id: UUID = UUID(), text: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// MARK: - Todo Filter

/// Filter options for displaying todos
public enum TodoFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Todo Service Protocol

/// Protocol for todo data operations
public protocol TodoServiceProtocol {
    func loadTodos() async throws -> [Todo]
    func saveTodos(_ todos: [Todo]) async throws
}

// MARK: - Mock Todo Service

/// Mock implementation of TodoService for demonstration
public struct MockTodoService: TodoServiceProtocol {
    private let defaultTodos: [Todo] = [
        Todo(text: "Learn TCAKit basics", isCompleted: true),
        Todo(text: "Build a todo app", isCompleted: false),
        Todo(text: "Add persistence", isCompleted: false),
        Todo(text: "Handle errors gracefully", isCompleted: true)
    ]
    
    public init() {}
    
    public func loadTodos() async throws -> [Todo] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Simulate occasional network errors (10% chance)
        if Int.random(in: 1...10) == 1 {
            throw TodoServiceError.networkError("Failed to load todos")
        }
        
        return defaultTodos
    }
    
    public func saveTodos(_ todos: [Todo]) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Simulate occasional network errors (5% chance)
        if Int.random(in: 1...20) == 1 {
            throw TodoServiceError.networkError("Failed to save todos")
        }
        
        // In a real implementation, this would save to a database or API
        // For the mock, we just simulate the operation
        print("Saved \(todos.count) todos")
    }
}

// MARK: - Todo Service Error

/// Errors that can occur in todo operations
public enum TodoServiceError: LocalizedError {
    case networkError(String)
    case validationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        }
    }
}

// MARK: - Dependencies Extension

/// Extension to add todo service to Dependencies
extension Dependencies {
    /// Provides todo service functionality
    public var todoService: TodoServiceProtocol {
        get { self[TodoServiceKey.self] }
        set { self[TodoServiceKey.self] = newValue }
    }
}

/// Key for todo service in Dependencies
private struct TodoServiceKey: DependencyKey {
    static let defaultValue: TodoServiceProtocol = MockTodoService()
}

/// Protocol for dependency keys
private protocol DependencyKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

/// Extension to make Dependencies subscriptable
extension Dependencies {
    fileprivate subscript<K: DependencyKey>(_ key: K.Type) -> K.Value {
        get {
            // In a real implementation, this would use a proper dependency container
            // For now, we'll use a simple approach with a static dictionary
            return key.defaultValue
        }
        set {
            // In a real implementation, this would store the value
            // For now, we'll ignore the setter
        }
    }
}
