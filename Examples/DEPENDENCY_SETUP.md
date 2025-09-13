# TCAKit Dependency Setup Guide

This guide shows you how to add TCAKit as a dependency to your Swift projects.

## 🚀 Quick Setup

### For Swift Package Manager Projects

Add TCAKit to your `Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    dependencies: [
        .package(path: "/path/to/tca-kit")  // Local path
        // OR
        .package(url: "https://github.com/ronstorm/tca-kit.git", from: "1.0.0")  // Remote
    ],
    targets: [
        .executableTarget(
            name: "YourApp",
            dependencies: [.product(name: "TCAKit", package: "tca-kit")]
        )
    ]
)
```

### For Xcode Projects

1. **File → Add Package Dependencies**
2. **Enter URL**: `https://github.com/ronstorm/tca-kit.git`
3. **Select version**: Latest or specific version
4. **Add to target**: Your app target

## 📱 Platform Requirements

- **iOS**: 15.0+
- **macOS**: 12.0+
- **tvOS**: 15.0+
- **watchOS**: 8.0+
- **Swift**: 5.9+

## 🔧 Common Issues & Solutions

### Issue: "Product 'TCAKit' not found"

**Problem**: Incorrect dependency declaration
**Solution**: Use the full product specification:

```swift
dependencies: [.product(name: "TCAKit", package: "tca-kit")]
```

### Issue: "Main actor-isolated" errors

**Problem**: Store operations need to be on MainActor
**Solution**: Use `@MainActor` or `await`:

```swift
@MainActor
func createStore() {
    let store = Store(/* ... */)
    // Use store here
}

// OR

func createStore() async {
    let store = await Store(/* ... */)
    // Use store here
}
```

### Issue: Build errors with async/await

**Problem**: Store initialization is async
**Solution**: Use proper async context:

```swift
// ✅ Correct
@MainActor
func setupStore() {
    let store = Store(/* ... */)
}

// ✅ Also correct
func setupStore() async {
    let store = await Store(/* ... */)
}

// ❌ Incorrect
func setupStore() {
    let store = Store(/* ... */)  // Error: async call in sync context
}
```

## 🎯 Usage Examples

### Basic Counter App

```swift
import TCAKit

struct CounterState {
    var count: Int = 0
}

enum CounterAction {
    case increment
    case decrement
}

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
    }
    return .none
}

@MainActor
class CounterViewModel: ObservableObject {
    let store: Store<CounterState, CounterAction>
    
    init() {
        self.store = Store(
            initialState: CounterState(),
            reducer: counterReducer,
            dependencies: Dependencies()
        )
    }
}
```

### SwiftUI Integration

```swift
import SwiftUI
import TCAKit

struct CounterView: View {
    let store: Store<CounterState, CounterAction>
    
    var body: some View {
        WithStore(store) { store in
            VStack {
                Text("Count: \(store.state.count)")
                
                HStack {
                    Button("−") { store.send(.decrement) }
                    Button("+") { store.send(.increment) }
                }
            }
        }
    }
}
```

## 🧪 Testing

### Using TestStore

```swift
import TCAKit

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
        .send(.decrement) { state in
            state.count = 0
        }
        .finish()
}
```

## 📦 Package Structure

When you add TCAKit as a dependency, you get access to:

- **Core**: `Store`, `Reducer`, `Effect`
- **Dependencies**: `Dependencies` system
- **SwiftUI**: `WithStore` helper
- **Testing**: `TestStore` utilities
- **Combine**: Bridge utilities

## 🔍 Verification

To verify TCAKit is working correctly:

1. **Import TCAKit** in your code
2. **Create a simple store** with basic state/action
3. **Test store operations** (send actions, read state)
4. **Run your app** - should work without errors

## 🆘 Troubleshooting

### Still having issues?

1. **Check Swift version**: Must be 5.9+
2. **Check platform versions**: Must meet minimum requirements
3. **Clean build folder**: ⌘+Shift+K in Xcode
4. **Reset package cache**: File → Packages → Reset Package Caches
5. **Check dependency path**: Ensure correct local path or URL

### Getting help

- 📖 **Documentation**: [README.md](../README.md)
- 🐛 **Report issues**: [GitHub Issues](https://github.com/ronstorm/tca-kit/issues)
- 💬 **Ask questions**: [GitHub Discussions](https://github.com/ronstorm/tca-kit/discussions)

---

**Ready to use TCAKit?** Follow the setup steps above and start building! 🚀
