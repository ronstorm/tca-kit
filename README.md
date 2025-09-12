# TCAKit

A lightweight, SwiftUI-first implementation of The Composable Architecture (TCA) patterns with one-way data flow, reducers, and effects. Designed to be easy to drop into SwiftUI apps with low boilerplate and async/await support.

## Features

- 🏪 **Store**: Manages state and handles actions with @MainActor publishing
- 🔄 **Reducer**: Pure functions that handle actions and return effects  
- ⚡ **Effect**: Represents async side effects with cancellation support
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

// Create your store
let store = Store(
    initialState: CounterState(),
    reducer: { state, action in
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
)

// Use in SwiftUI
struct CounterView: View {
    @StateObject private var store = store
    
    var body: some View {
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
```

### With Effects

```swift
enum AppAction {
    case loadData
    case dataLoaded(String)
    case loadFailed
}

let store = Store(
    initialState: AppState(),
    reducer: { state, action in
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
    }
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

let appStore = Store(
  initialState: AppState(),
  reducer: { state, action in
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
  }
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

### Effect Cancellation

You can mark effects as cancellable by an identifier and optionally cancel in-flight work.

```swift
enum AppAction {
    case load
    case cancelLoad
    case loaded(String)
}

let store = Store(
    initialState: AppState(),
    reducer: { state, action in
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
    }
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
