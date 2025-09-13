# BasicCounter Example

A simple counter app demonstrating core TCAKit concepts.

## What You'll Learn

- **State Management**: Define and manage app state
- **Actions**: Handle user interactions
- **Reducers**: Process actions and update state
- **SwiftUI Integration**: Use `WithStore` for seamless integration

## The App

Simple counter with three actions:
- **Increment**: Increase count by 1
- **Decrement**: Decrease count by 1  
- **Reset**: Set count to 0

## Key Code

```swift
// State
struct CounterState {
    var count: Int = 0
}

// Actions
enum CounterAction {
    case increment, decrement, reset
}

// Reducer
func counterReducer(state: inout CounterState, action: CounterAction, dependencies: Dependencies) -> Effect<CounterAction> {
    switch action {
    case .increment: state.count += 1
    case .decrement: state.count -= 1
    case .reset: state.count = 0
    }
    return .none
}

// SwiftUI View
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

// Complete App (standalone)
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

## Running

**Option 1: Standalone App (Easiest)**
1. Copy `BasicCounter.swift` to your project
2. Add TCAKit as a dependency
3. Run immediately! (⌘+R)

**Option 2: Integration**
1. Copy the code into your existing app
2. Add TCAKit as a dependency
3. Update your `App.swift` to use `CounterApp()`

## Next Steps

- [TodoList Example](../TodoList/) - Learn complex state and effects
- [WeatherApp Example](../WeatherApp/) - Learn network requests