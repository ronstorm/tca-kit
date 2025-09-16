# SwiftUI Integration

TCAKit is designed to work seamlessly with SwiftUI. Learn the best practices for integrating TCAKit stores with SwiftUI views.

## Overview

TCAKit provides:
- `WithStore` for ergonomic store usage
- `@ObservedObject` and `@StateObject` support
- Automatic state observation
- Main thread safety

## Basic Integration

### WithStore
Use `WithStore` to access the store in your views:

```swift
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

### Store Observation
Always use `@ObservedObject` for views that receive stores:

```swift
struct MyView: View {
    @ObservedObject var store: Store<MyState, MyAction>
    // ✅ Correct - SwiftUI will observe state changes
}
```

## App-Level Store Management

### StateObject
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
            ContentView(store: store)
        }
    }
}
```

## Bindings

### Store Binding
Create bindings that read from state and send actions:

```swift
extension Store {
    func binding<Value>(
        get: @escaping (State) -> Value,
        send: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { get(self.state) },
            set: { self.send(send($0)) }
        )
    }
}

// Usage
TextField("Name", text: store.binding(
    get: \.name,
    send: AppAction.nameChanged
))
```

### Picker Binding
```swift
Picker("Filter", selection: store.binding(
    get: \.filter,
    send: AppAction.filterChanged
)) {
    ForEach(Filter.allCases, id: \.self) { filter in
        Text(filter.rawValue).tag(filter)
    }
}
```

## Navigation

### NavigationView with Store
```swift
struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithStore(store) { store in
                List {
                    ForEach(store.state.items) { item in
                        NavigationLink(
                            destination: DetailView(
                                store: store.scope(
                                    state: \.detail,
                                    action: AppAction.detail
                                )
                            )
                        ) {
                            Text(item.name)
                        }
                    }
                }
            }
            .navigationTitle("Items")
        }
    }
}
```

## Scoped Stores

### Child Views
Pass scoped stores to child views:

```swift
struct ParentView: View {
    @ObservedObject var store: Store<ParentState, ParentAction>
    
    var body: some View {
        VStack {
            ChildView(
                store: store.scope(
                    state: \.child,
                    action: ParentAction.child
                )
            )
        }
    }
}
```

## Loading States

### Progress Indicators
```swift
struct DataView: View {
    @ObservedObject var store: Store<DataState, DataAction>
    
    var body: some View {
        WithStore(store) { store in
            VStack {
                if store.state.isLoading {
                    ProgressView("Loading...")
                } else {
                    List(store.state.items) { item in
                        Text(item.name)
                    }
                }
            }
        }
    }
}
```

## Error Handling

### Alerts
```swift
struct MyView: View {
    @ObservedObject var store: Store<MyState, MyAction>
    
    var body: some View {
        WithStore(store) { store in
            VStack {
                // Your content
            }
            .alert("Error", isPresented: .constant(store.state.error != nil)) {
                Button("OK") {
                    store.send(.clearError)
                }
            } message: {
                Text(store.state.error ?? "")
            }
        }
    }
}
```

## Performance

### View Updates
TCAKit automatically optimizes view updates:
- Only views that use changed state will re-render
- `WithStore` provides efficient state observation
- Store operations are `@MainActor` for thread safety

### Large Lists
For large lists, consider using `LazyVStack` or `LazyVGrid`:

```swift
ScrollView {
    LazyVStack {
        ForEach(store.state.items) { item in
            ItemRowView(item: item) {
                store.send(.itemTapped(item.id))
            }
        }
    }
}
```

## Best Practices

1. **Use `@ObservedObject`** for views that receive stores
2. **Use `@StateObject`** for app-level store management
3. **Always use `WithStore`** to access store in views
4. **Create bindings** for form inputs
5. **Scope stores** for child views
6. **Handle loading and error states** in your UI

## Common Patterns

### Form View
```swift
struct FormView: View {
    @ObservedObject var store: Store<FormState, FormAction>
    
    var body: some View {
        WithStore(store) { store in
            Form {
                TextField("Name", text: store.binding(
                    get: \.name,
                    send: FormAction.nameChanged
                ))
                
                Button("Submit") {
                    store.send(.submit)
                }
                .disabled(!store.state.isValid)
            }
        }
    }
}
```

### List with Actions
```swift
struct ItemListView: View {
    @ObservedObject var store: Store<ItemListState, ItemListAction>
    
    var body: some View {
        WithStore(store) { store in
            List {
                ForEach(store.state.items) { item in
                    ItemRowView(item: item) {
                        store.send(.itemTapped(item.id))
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let item = store.state.items[index]
                        store.send(.deleteItem(item.id))
                    }
                }
            }
        }
    }
}
```

## Next Steps

- [Store](store.md) - Learn more about stores
- [Examples](../Examples/) - See SwiftUI integration in action
