<div align="center">

# TCAKit

[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fronstorm%2Ftca-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ronstorm/tca-kit)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fronstorm%2Ftca-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ronstorm/tca-kit)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/ronstorm/tca-kit/releases)

</div>

A lightweight, SwiftUI-first implementation of The Composable Architecture (TCA) patterns with one-way data flow, reducers, and effects. Designed to be easy to drop into SwiftUI apps with low boilerplate and async/await support.

## Features

- **Store**: Manages state and handles actions with @MainActor publishing
- **Reducer**: Pure functions that handle actions and return effects  
- **Effect**: Represents async side effects with cancellation support
- **Dependencies**: Environment-based dependency injection for services
- **WithStore**: SwiftUI helper for ergonomic store usage in views
- **TestStore**: Testing utility with fluent assertions and transcripts
- **CombineBridge**: Seamless integration between Combine publishers and TCAKit effects
- **SwiftUI-First**: Built specifically for SwiftUI with @MainActor integration
- **Cross-platform**: iOS, macOS, tvOS, and watchOS support
- **Lightweight**: No external dependencies
- **Modern Swift**: Swift 5.9+ with Concurrency support

## Quick Start

### 1. Installation

Add TCAKit to your project:

```swift
dependencies: [
    .package(url: "https://github.com/ronstorm/tca-kit.git", from: "1.0.0")
]
```

### 2. Basic Usage

```swift
import TCAKit
import SwiftUI

// State
struct CounterState {
    var count: Int = 0
}

// Actions
enum CounterAction {
    case increment, decrement, reset
}

// Reducer
func counterReducer(
    state: inout CounterState,
    action: CounterAction,
    dependencies: Dependencies
) -> Effect<CounterAction> {
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

// Complete App
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

## Documentation

**[Complete Documentation](Docs/README.md)** - Comprehensive guide to TCAKit

### Core Concepts
- **[Store](Docs/store.md)** - State management and action handling
- **[Reducer](Docs/reducer.md)** - Pure functions for state updates
- **[Effect](Docs/effect.md)** - Async side effects with cancellation
- **[Dependencies](Docs/dependencies.md)** - Dependency injection system
- **[SwiftUI Integration](Docs/swiftui-integration.md)** - Best practices for SwiftUI

## Examples

Ready-to-run examples showcasing TCAKit patterns:

### [BasicCounter](Examples/BasicCounter/) - **Start Here**
Simple counter app demonstrating core TCAKit concepts.
- **Files**: `BasicCounter.swift` (standalone app)
- **Learn**: State, actions, reducers, SwiftUI integration

### [TodoList](Examples/TodoList/) - **Intermediate**
Full-featured todo list with CRUD operations and effects.
- **Files**: `TodoList.swift` + `Models.swift` (standalone app)
- **Learn**: Complex state, async effects, extending Dependencies, error handling

### [WeatherApp](Examples/WeatherApp/) - **Advanced**
Weather app with network requests and real-world patterns.
- **Files**: `WeatherApp.swift` + `Models.swift` (standalone app)
- **Learn**: Network requests, effect cancellation, extending Dependencies, complex state

**Quick Start**: Copy any example files to your project, add TCAKit dependency, and run immediately! See [Examples/SETUP.md](Examples/SETUP.md) for detailed instructions.

## Requirements

- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+
- Swift 5.9+
- SwiftUI

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on [GitHub](https://github.com/ronstorm/tca-kit).

## Author

Created by [Amit Sen](https://github.com/ronstorm)