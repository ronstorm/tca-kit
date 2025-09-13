//  Models.swift
//  TCAKit Examples
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation

// MARK: - Todo Model

/// Represents a single todo item
struct Todo: Identifiable, Equatable, Codable {
    let id: UUID
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
enum TodoFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Todo Service Protocol

/// Protocol for todo data operations
protocol TodoServiceProtocol {
    func loadTodos() async throws -> [Todo]
    func saveTodos(_ todos: [Todo]) async throws
}

// MARK: - Mock Todo Service

/// Mock implementation of TodoService for demonstration
struct MockTodoService: TodoServiceProtocol {
    private var todos: [Todo] = []
    
    init() {
        // Initialize with some sample data
        self.todos = [
            Todo(text: "Learn TCAKit basics", isCompleted: true),
            Todo(text: "Build a todo app", isCompleted: false),
            Todo(text: "Add persistence", isCompleted: false),
            Todo(text: "Handle errors gracefully", isCompleted: true)
        ]
    }
    
    func loadTodos() async throws -> [Todo] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Simulate occasional network errors (10% chance)
        if Int.random(in: 1...10) == 1 {
            throw TodoServiceError.networkError("Failed to load todos")
        }
        
        return todos
    }
    
    func saveTodos(_ todos: [Todo]) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Simulate occasional network errors (5% chance)
        if Int.random(in: 1...20) == 1 {
            throw TodoServiceError.networkError("Failed to save todos")
        }
        
        self.todos = todos
    }
}

// MARK: - Todo Service Error

/// Errors that can occur in todo operations
enum TodoServiceError: LocalizedError {
    case networkError(String)
    case validationError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        }
    }
}
