# TCAKit

A lightweight, SwiftUI-first implementation of The Composable Architecture (TCA) patterns with one-way data flow, reducers, and effects. Designed to be easy to drop into SwiftUI apps with low boilerplate and async/await support.

## Features

- 🏪 **Store**: Manages state and handles actions with @MainActor publishing
- 🔄 **Reducer**: Pure functions that handle actions and return effects  
- ⚡ **Effect**: Represents async side effects with cancellation support
- 🔧 **Dependencies**: Environment-based dependency injection for services
- 🎯 **WithStore**: SwiftUI helper for ergonomic store usage in views
- 🧪 **TestStore**: Testing utility with fluent assertions and transcripts
- 🎯 **SwiftUI-First**: Built specifically for SwiftUI with @MainActor integration
- 📱 **Cross-platform**: iOS, macOS, tvOS, and watchOS support
- 🚀 **Lightweight**: No external dependencies
- ⚡ **Modern Swift**: Swift 5.9+ with Concurrency support

## Installation

### Swift Package Manager

Add TCAKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ronstorm/tca-kit.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["TCAKit"]
)
```

## Usage

### Basic Counter Example

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

// Create your store with dependencies
let dependencies = Dependencies()
let store = Store(
    initialState: CounterState(),
    reducer: { state, action, dependencies in
        switch action {
        case .increment:
            state.count += 1
        case .decrement:
            state.count -= 1
        case .reset:
            state.count = 0
        }
        return .none
    },
    dependencies: dependencies
)

// Use in SwiftUI with WithStore
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

### With Effects

```swift
enum AppAction {
    case loadData
    case dataLoaded(String)
    case loadFailed
}

let dependencies = Dependencies()
let store = Store(
    initialState: AppState(),
    reducer: { state, action, dependencies in
        switch action {
        case .loadData:
            // Return an effect that loads data
            return .task(
                operation: {
                    // Simulate network request
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    return "Hello, World!"
                },
                transform: AppAction.dataLoaded
            )
        case .dataLoaded(let data):
            state.message = data
        case .loadFailed:
            state.error = "Failed to load data"
        }
        return .none
    },
    dependencies: dependencies
)
```

### Scoping (Child Stores) and Effect Mapping

You can scope a parent store to a child feature so it sees only the relevant state and actions.
An overload also lets you map parent effect outputs back into local actions.

```swift
struct AppState {
  var counter: CounterState = .init()
}

enum AppAction {
  case counter(CounterAction)
  case loaded(Int)
}

let dependencies = Dependencies()
let appStore = Store(
  initialState: AppState(),
  reducer: { state, action, dependencies in
    switch action {
    case .counter(let local):
      switch local {
      case .increment:
        state.counter.count += 1
        // Parent effect emits a parent action
        return Effect<AppAction>
          .task(
            operation: {
              try? await Task.sleep(nanoseconds: 50_000_000)
              return 5
            },
            transform: { .loaded($0) }
          )
      case .decrement:
        state.counter.count -= 1
      case .reset:
        state.counter.count = 0
      case .setCount(let value):
        state.counter.count = value
      }
      return .none
    case .loaded(let value):
      state.counter.count = value
      return .none
    }
  },
  dependencies: dependencies
)

// Child store that maps parent actions back to local actions for effects
let counterStore = await appStore.scope(
  state: \AppState.counter,
  action: AppAction.counter,
  toLocalAction: { (action: AppAction) -> CounterAction? in
    switch action {
    case .loaded(let value):
      return .setCount(value)
    case .counter:
      return nil
    }
  }
)
```

### Dependencies

TCAKit provides a dependency injection system for services like date providers, UUID generators, and HTTP clients.

```swift
// Create dependencies
let dependencies = Dependencies()

// Use in reducer
func appReducer(state: inout AppState, action: AppAction, dependencies: Dependencies) -> Effect<AppAction> {
    switch action {
    case .getCurrentTime:
        let currentTime = dependencies.date()
        state.timestamp = currentTime
        return .none
    case .generateId:
        let newId = dependencies.uuid()
        state.id = newId.uuidString
        return .none
    case .loadData:
        return .task {
            let url = URL(string: "https://api.example.com/data")!
            let data = try await dependencies.httpClient(url)
            return .dataLoaded(String(data: data, encoding: .utf8) ?? "")
        }
    case .dataLoaded(let data):
        state.data = data
        return .none
    }
}

// For testing, use test dependencies
let testDependencies = Dependencies.test
let store = Store(
    initialState: AppState(),
    reducer: appReducer,
    dependencies: testDependencies
)

// Or create custom mock dependencies
let mockDependencies = Dependencies.mock(
    date: { Date(timeIntervalSince1970: 0) },
    uuid: { UUID(uuidString: "12345678-1234-1234-1234-123456789012")! },
    httpClient: { _ in "mock data".data(using: .utf8)! }
)
```

### WithStore SwiftUI Helper

TCAKit provides `WithStore`, a SwiftUI helper that makes it easy to use stores in views with proper lifecycle management.

```swift
struct CounterView: View {
    let store: Store<CounterState, CounterAction>
    
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

#### Scoped Stores with WithStore

WithStore works seamlessly with scoped stores for better modularity:

```swift
struct AppView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithStore(store) { store in
            VStack {
                Text("App Message: \(store.state.message)")
                
                // Scoped store for counter
                WithStore(store.scope(state: \.counter, action: AppAction.counter)) { counterStore in
                    CounterView(store: counterStore)
                }
            }
        }
    }
}
```

#### Store Extension

You can also use the convenient `withStore` extension:

```swift
struct MyView: View {
    let store: Store<MyState, MyAction>
    
    var body: some View {
        store.withStore { store in
            Text("State: \(store.state)")
        }
    }
}
```

#### Benefits of WithStore

- **Better Testing**: Easy to inject test stores into views
- **Cleaner Code**: No global store dependencies
- **Flexible**: Different store configurations per view
- **TCA Aligned**: Follows standard TCA patterns

### TestStore Testing Utility

TCAKit provides `TestStore`, a powerful testing utility that makes it easy to test store behavior with fluent assertions and automatic transcript generation.

#### Basic Testing

```swift
func testCounter() async throws {
    let store = TestStore(
        initialState: CounterState(count: 0),
        reducer: counterReducer,
        dependencies: Dependencies.test
    )

    await store
        .send(.increment) { state in
            state.count = 1
        }
        .send(.increment) { state in
            state.count = 2
        }
        .send(.reset) { state in
            state.count = 0
        }
        .finish()
}
```

#### Effect Testing

TestStore makes it easy to test async effects and their resulting state changes:

```swift
func testDataLoading() async throws {
    let store = TestStore(
        initialState: AppState(),
        reducer: appReducer,
        dependencies: Dependencies.test
    )

    await store
        .send(.loadData) { state in
            state.isLoading = true
        }
        .receive(.dataLoaded("test data")) { state in
            state.isLoading = false
            state.data = "test data"
        }
        .finish()
}
```

#### Complex State Testing

TestStore handles complex state changes and nested actions:

```swift
func testComplexFlow() async throws {
    let store = TestStore(
        initialState: AppState(),
        reducer: appReducer,
        dependencies: Dependencies.test
    )

    await store
        .send(.counter(.increment)) { state in
            state.counter.count = 1
        }
        .send(.loadData) { state in
            state.isLoading = true
        }
        .receive(.dataLoaded("result")) { state in
            state.isLoading = false
            state.data = "result"
        }
        .send(.counter(.setMessage("Done"))) { state in
            state.counter.message = "Done"
        }
        .finish()
}
```

#### Test Transcripts

TestStore automatically generates transcripts for debugging and documentation:

```swift
let transcript = await store
    .send(.increment) { state in
        state.count = 1
    }
    .finish()

print(transcript.description)
// Output:
// Test Transcript:
// 1. Send increment - State: CounterState(count: 0) → CounterState(count: 1)
```

#### Benefits of TestStore

- **Fluent API**: Easy to read and write tests
- **Automatic Transcripts**: Clear record of test execution
- **State Assertions**: Built-in state change verification
- **Effect Testing**: Proper async effect testing support
- **Debugging**: Easy to see test failures and state changes
- **Documentation**: Tests serve as living documentation

### Effect Cancellation

You can mark effects as cancellable by an identifier and optionally cancel in-flight work.

```swift
enum AppAction {
    case load
    case cancelLoad
    case loaded(String)
}

let dependencies = Dependencies()
let store = Store(
    initialState: AppState(),
    reducer: { state, action, dependencies in
        switch action {
        case .load:
            return Effect<AppAction>
                .task(
                    operation: {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        return "Result"
                    },
                    transform: AppAction.loaded
                )
                .cancellable(id: "load", cancelInFlight: true)

        case .cancelLoad:
            return .cancel(id: "load")

        case .loaded(let value):
            state.message = value
            return .none
        }
    },
    dependencies: dependencies
)
```

## Requirements

- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+
- Swift 5.9+
- Swift Concurrency support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

We also have a [Code of Conduct](CODE_OF_CONDUCT.md) that all contributors are expected to follow.

## Author

Created by [Amit Sen](https://github.com/ronstorm)

---

**Note**: This is a work in progress. More utilities and patterns will be added in future releases.
