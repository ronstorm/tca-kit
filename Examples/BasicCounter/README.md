# BasicCounter Example

A simple counter app that demonstrates the fundamental concepts of TCAKit. This is the perfect starting point for learning TCAKit patterns.

## What This Example Teaches

- **State Management**: How to define and manage app state
- **Actions**: How to define actions that represent user interactions
- **Reducers**: How to handle actions and update state
- **SwiftUI Integration**: How to use `WithStore` for seamless SwiftUI integration
- **Store Creation**: How to create and configure a TCAKit store

## The Counter App

This example creates a simple counter with three actions:
- **Increment**: Increase the count by 1
- **Decrement**: Decrease the count by 1  
- **Reset**: Set the count back to 0

## Code Walkthrough

### 1. Define the State

```swift
struct CounterState {
    var count: Int = 0
}
```

The state is a simple struct containing the current count. It starts at 0.

### 2. Define the Actions

```swift
enum CounterAction {
    case increment
    case decrement
    case reset
}
```

Actions represent all the things that can happen in our app. Each case corresponds to a user interaction.

### 3. Create the Reducer

```swift
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
```

The reducer is a pure function that:
- Takes the current state (as `inout` so it can be modified)
- Takes an action
- Takes dependencies (for external services)
- Returns an effect (`.none` means no side effects)

### 4. Create the Store

```swift
let dependencies = Dependencies()
let store = Store(
    initialState: CounterState(),
    reducer: counterReducer,
    dependencies: dependencies
)
```

The store manages the state and handles actions. It's the central piece that connects everything together.

### 5. Build the SwiftUI View

```swift
struct CounterView: View {
    let store: Store<CounterState, CounterAction>
    
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
```

`WithStore` provides a clean way to use the store in SwiftUI. It automatically handles state observation and updates the view when the state changes.

## Key TCAKit Concepts

### One-Way Data Flow
- **State** flows down to views
- **Actions** flow up from views to the store
- **Reducers** process actions and update state

### Pure Functions
- Reducers are pure functions with no side effects
- This makes them easy to test and reason about
- Side effects are handled separately through the Effect system

### SwiftUI Integration
- `WithStore` provides seamless integration
- Views automatically update when state changes
- No manual state observation needed

## Running the Example

1. Copy the code from `BasicCounter.swift`
2. Add TCAKit as a dependency to your project
3. Create a new SwiftUI view and paste the code
4. Run the app and try the buttons!

## Next Steps

Once you understand this example, try:
- [TodoList Example](../TodoList/) - Learn about complex state and effects
- [WeatherApp Example](../WeatherApp/) - Learn about network requests and error handling

## Common Patterns

### Button Actions
```swift
Button("Increment") { store.send(.increment) }
```

### State Access
```swift
Text("Count: \(store.state.count)")
```

### Store Creation
```swift
let store = Store(
    initialState: CounterState(),
    reducer: counterReducer,
    dependencies: Dependencies()
)
```

This example demonstrates the core TCAKit patterns that you'll use in every app. The simplicity makes it easy to understand the fundamental concepts before moving on to more complex examples.
