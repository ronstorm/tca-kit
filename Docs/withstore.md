# WithStore

`WithStore` is a SwiftUI helper that provides ergonomic access to TCAKit stores in your views. It automatically handles the observation of state changes and provides a clean API for sending actions.

## Basic Usage

```swift
import TCAKit
import SwiftUI

struct CounterView: View {
    @ObservedObject var store: Store<CounterState, CounterAction>
    
    var body: some View {
        WithStore(store) { store in
            VStack {
                Text("Count: \(store.state.count)")
                Button("Increment") {
                    store.send(.increment)
                }
            }
        }
    }
}
```

## How It Works

`WithStore` takes your store and provides a closure with a scoped store that:

- **Automatically observes state changes** - No need to manually handle `@Published` properties
- **Provides type-safe access** - The closure receives a properly typed store
- **Handles view updates** - SwiftUI automatically re-renders when state changes

## Advanced Usage

### Custom Store Access

```swift
WithStore(store) { store in
    VStack {
        // Access state
        Text("Count: \(store.state.count)")
        
        // Send actions
        Button("Increment") {
            store.send(.increment)
        }
        
        // Access dependencies if needed
        Button("Load Data") {
            store.send(.loadData)
        }
    }
}
```

### Conditional Rendering

```swift
WithStore(store) { store in
    if store.state.isLoading {
        ProgressView()
    } else {
        VStack {
            Text("Data: \(store.state.data)")
            Button("Refresh") {
                store.send(.refresh)
            }
        }
    }
}
```

## Best Practices

1. **Always use `@ObservedObject`** - This ensures proper observation
2. **Keep closures focused** - Don't put complex logic in the WithStore closure
3. **Use computed properties** - Extract complex view logic to computed properties
4. **Leverage type safety** - The store parameter is fully typed

## Integration with SwiftUI

`WithStore` is designed to work seamlessly with SwiftUI's declarative syntax:

```swift
struct TodoListView: View {
    @ObservedObject var store: Store<TodoListState, TodoListAction>
    
    var body: some View {
        WithStore(store) { store in
            NavigationView {
                List {
                    ForEach(store.state.todos) { todo in
                        TodoRowView(todo: todo) {
                            store.send(.toggleTodo(id: todo.id))
                        }
                    }
                }
                .navigationTitle("Todos")
                .toolbar {
                    Button("Add") {
                        store.send(.addTodo)
                    }
                }
            }
        }
    }
}
```

This pattern keeps your views clean and focused on presentation while maintaining the unidirectional data flow that TCAKit provides.
