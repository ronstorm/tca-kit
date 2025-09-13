# TodoList Example

A comprehensive todo list app demonstrating intermediate TCAKit patterns.

## What You'll Learn

- **Complex State Management**: Managing arrays and multiple states
- **CRUD Operations**: Create, Read, Update, Delete operations
- **Effects**: Async operations with loading states
- **Extending Dependencies**: How to add custom services to TCAKit's Dependencies
- **Dependency Injection**: Using custom services in reducers
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

// Extending Dependencies
extension Dependencies {
    public var todoService: TodoServiceProtocol {
        get { self[TodoServiceKey.self] }
        set { self[TodoServiceKey.self] = newValue }
    }
}

private struct TodoServiceKey: DependencyKey {
    static let defaultValue: TodoServiceProtocol = MockTodoService()
}

// Complete App (standalone)
@main
struct TodoListApp: App {
    private let dependencies: Dependencies
    private let store: Store<TodoListState, TodoListAction>
    
    init() {
        // Mock service for demonstration
        self.dependencies = Dependencies().with(\.todoService, MockTodoService())
        self.store = Store(
            initialState: TodoListState(),
            reducer: todoListReducer,
            dependencies: dependencies
        )
    }
    
    var body: some Scene {
        WindowGroup {
            TodoListView(store: store)
        }
    }
}
```

## Running

**Option 1: Standalone App (Easiest)**
1. Copy both `TodoList.swift` and `Models.swift` to your project
2. Add TCAKit as a dependency
3. Run immediately! (⌘+R)

**Option 2: Integration**
1. Copy both files into your existing app
2. Add TCAKit as a dependency
3. Update your `App.swift` to use `TodoListApp()`

**Note**: Uses `MockTodoService` for demonstration - no real network calls needed!

## Next Steps

- [WeatherApp Example](../WeatherApp/) - Learn network requests and advanced patterns