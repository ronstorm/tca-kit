# TodoList Example

A comprehensive todo list app that demonstrates intermediate TCAKit patterns including CRUD operations, effects, dependencies, and error handling.

## What This Example Teaches

- **Complex State Management**: Managing arrays of items with different states
- **CRUD Operations**: Create, Read, Update, Delete operations
- **Effects with Async Operations**: Simulating network requests and data persistence
- **Dependency Injection**: Using custom services for data operations
- **Error Handling**: Managing and displaying error states
- **Loading States**: Showing loading indicators during async operations
- **Form Handling**: Adding new todos with validation
- **List Management**: Filtering and managing todo items

## The TodoList App

This example creates a full-featured todo list with:
- **Add Todo**: Create new todo items with text input
- **Toggle Complete**: Mark todos as complete/incomplete
- **Delete Todo**: Remove todos from the list
- **Filter Todos**: Show all, active, or completed todos
- **Persistence**: Simulate saving todos to a service
- **Error Handling**: Handle and display errors
- **Loading States**: Show loading indicators

## Code Walkthrough

### 1. Define the Models

```swift
struct Todo: Identifiable, Equatable {
    let id: UUID
    var text: String
    var isCompleted: Bool
    let createdAt: Date
}
```

### 2. Define the State

```swift
struct TodoListState {
    var todos: [Todo] = []
    var newTodoText: String = ""
    var filter: TodoFilter = .all
    var isLoading: Bool = false
    var errorMessage: String?
}
```

The state includes:
- Array of todos
- Current text input for new todos
- Filter selection
- Loading state
- Error message

### 3. Define the Actions

```swift
enum TodoListAction {
    case addTodo
    case newTodoTextChanged(String)
    case toggleTodo(UUID)
    case deleteTodo(UUID)
    case filterChanged(TodoFilter)
    case loadTodos
    case todosLoaded([Todo])
    case saveTodos
    case todosSaved
    case errorOccurred(String)
    case clearError
}
```

### 4. Create Services

```swift
struct TodoService {
    func loadTodos() async throws -> [Todo]
    func saveTodos(_ todos: [Todo]) async throws
}
```

### 5. Handle Effects

```swift
case .loadTodos:
    state.isLoading = true
    return .task {
        let todos = try await dependencies.todoService.loadTodos()
        return .todosLoaded(todos)
    }
```

## Key TCAKit Patterns

### Effect Handling
- Use `.task` for async operations
- Handle success and error cases
- Update loading states appropriately

### Dependency Injection
- Inject services through the Dependencies system
- Use test dependencies for testing
- Keep business logic separate from UI

### Error Handling
- Store error messages in state
- Display errors in the UI
- Provide ways to clear errors

### Complex State Updates
- Update arrays safely
- Handle optional states
- Maintain data consistency

## Running the Example

1. Copy the code from the TodoList files
2. Add TCAKit as a dependency to your project
3. Create a new SwiftUI view and paste the code
4. Run the app and try all the features!

## Features Demonstrated

### Adding Todos
- Text input with validation
- Add button that creates new todos
- Automatic text field clearing

### Managing Todos
- Toggle completion status
- Delete todos with swipe actions
- Visual feedback for completed items

### Filtering
- Filter by all, active, or completed
- Dynamic list updates
- Filter state persistence

### Persistence
- Simulated network requests
- Loading indicators
- Error handling and retry

## Next Steps

After understanding this example:
- [WeatherApp Example](../WeatherApp/) - Learn about real network requests
- Try adding features like editing todos, due dates, or categories
- Experiment with different UI layouts and interactions

## Common Patterns

### Array Updates
```swift
case .toggleTodo(let id):
    if let index = state.todos.firstIndex(where: { $0.id == id }) {
        state.todos[index].isCompleted.toggle()
    }
```

### Async Effects
```swift
case .loadTodos:
    return .task {
        let todos = try await dependencies.todoService.loadTodos()
        return .todosLoaded(todos)
    }
```

### Error Handling
```swift
case .errorOccurred(let message):
    state.errorMessage = message
    state.isLoading = false
```

This example demonstrates how TCAKit scales to handle complex, real-world applications with multiple features and state management needs.
