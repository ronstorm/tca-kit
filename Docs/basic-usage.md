# Basic Usage

Learn how to create your first TCAKit app with a simple counter example.

## Your First TCAKit App

Here's a complete, runnable counter app:

```swift
import TCAKit
import SwiftUI

// Define your state
struct CounterState {
    var count: Int = 0
}

// Define your actions
enum CounterAction {
    case increment
    case decrement
    case reset
}

// Create your reducer
func counterReducer(
    state: inout CounterState,
    action: CounterAction,
    dependencies: Dependencies
) -> Effect<CounterAction> {
    switch action {
    case .increment:
        state.count += 1
    case .decrement:
        state.count -= 1
    case .reset:
        state.count = 0
    }
    return .none
}

// Create your SwiftUI view
struct CounterView: View {
    @ObservedObject var store: Store<CounterState, CounterAction>
    
    var body: some View {
        WithStore(store) { store in
            VStack {
                Text("Count: \(store.state.count)")
                
                HStack {
                    Button("−") { store.send(.decrement) }
                    Button("Reset") { store.send(.reset) }
                    Button("+") { store.send(.increment) }
                }
            }
        }
    }
}

// Create your app
@main
struct CounterApp: App {
    @StateObject private var store: Store<CounterState, CounterAction>
    
    init() {
        let dependencies = Dependencies()
        self._store = StateObject(wrappedValue: Store(
            initialState: CounterState(),
            reducer: counterReducer,
            dependencies: dependencies
        ))
    }
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: store)
        }
    }
}
```

## Key Concepts

### State
Your app's data model. Must be a struct.

### Actions
All possible user interactions. Must be an enum.

### Reducer
Pure function that handles actions and updates state.

### Store
Manages state and processes actions through the reducer.

### WithStore
SwiftUI helper that provides the store to your views.

## Next Steps

- [Store](store.md) - Learn more about the Store
- [Reducer](reducer.md) - Understand reducers in detail
- [Effect](effect.md) - Handle async operations
- [Examples](../Examples/) - Try more complex examples
