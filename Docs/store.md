# Store

The Store is the central component of TCAKit. It manages your app's state and processes actions through reducers.

## Overview

The Store:
- Holds the current state
- Processes actions through reducers
- Publishes state changes for SwiftUI observation
- Manages effects and their lifecycle

## Creating a Store

```swift
let dependencies = Dependencies()
let store = Store(
    initialState: AppState(),
    reducer: appReducer,
    dependencies: dependencies
)
```

## Store Properties

### State
The current state of your app:

```swift
let currentCount = store.state.count
```

### Sending Actions
Send actions to update state:

```swift
store.send(.increment)
store.send(.loadData)
```

## SwiftUI Integration

### WithStore
Use `WithStore` to access the store in SwiftUI:

```swift
struct MyView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
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

### App-Level Store
Use `@StateObject` for app-level store management:

```swift
@main
struct MyApp: App {
    @StateObject private var store: Store<AppState, AppAction>
    
    init() {
        let dependencies = Dependencies()
        self._store = StateObject(wrappedValue: Store(
            initialState: AppState(),
            reducer: appReducer,
            dependencies: dependencies
        ))
    }
    
    var body: some Scene {
        WindowGroup {
            MyView(store: store)
        }
    }
}
```

## Scoping

Create child stores for modular architecture:

```swift
// Parent store
let parentStore = Store(
    initialState: AppState(),
    reducer: appReducer,
    dependencies: dependencies
)

// Child store
let childStore = parentStore.scope(
    state: \.counter,
    action: AppAction.counter
)
```

## Thread Safety

- Store operations are `@MainActor` - always run on the main thread
- State changes automatically trigger SwiftUI updates
- Effects run asynchronously and send actions back to the main thread

## Best Practices

1. **Use `@ObservedObject`** for views that receive stores
2. **Use `@StateObject`** for app-level store management
3. **Keep stores focused** - scope to specific features when needed
4. **Inject dependencies** - use the Dependencies system for services

## Next Steps

- [Reducer](reducer.md) - Learn how reducers work
- [SwiftUI Integration](swiftui-integration.md) - Best practices
