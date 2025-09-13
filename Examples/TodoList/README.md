# TodoList Example

A comprehensive todo list app demonstrating intermediate TCAKit patterns.

## What You'll Learn

- **Complex State Management**: Managing arrays and multiple states
- **CRUD Operations**: Create, Read, Update, Delete operations
- **Effects**: Async operations with loading states
- **Dependency Injection**: Using custom services
- **Error Handling**: Managing and displaying errors

## Features

- **Add Todo**: Create new todo items
- **Toggle Complete**: Mark todos as complete/incomplete
- **Delete Todo**: Remove todos from the list
- **Filter Todos**: Show all, active, or completed todos
- **Persistence**: Simulate saving todos to a service
- **Error Handling**: Handle and display errors
- **Loading States**: Show loading indicators

## Key Patterns

```swift
// Complex State
struct TodoListState {
    var todos: [Todo] = []
    var newTodoText: String = ""
    var filter: TodoFilter = .all
    var isLoading: Bool = false
    var errorMessage: String?
}

// Async Effects
case .loadTodos:
    state.isLoading = true
    return .task {
        let todos = try await dependencies.todoService.loadTodos()
        return .todosLoaded(todos)
    }

// Array Updates
case .toggleTodo(let id):
    if let index = state.todos.firstIndex(where: { $0.id == id }) {
        state.todos[index].isCompleted.toggle()
    }
```

## Running

1. Copy both `TodoList.swift` and `Models.swift`
2. Add TCAKit as a dependency
3. Run the app!

## Next Steps

- [WeatherApp Example](../WeatherApp/) - Learn network requests and advanced patterns