# Reducer

Reducers are pure functions that handle actions and update state. They're the heart of TCAKit's unidirectional data flow.

## Overview

Reducers:
- Are pure functions (no side effects)
- Take current state, action, and dependencies
- Return effects for side effects
- Update state by modifying the `inout` parameter

## Basic Reducer

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

## Reducer Signature

```swift
func myReducer(
    state: inout MyState,        // Current state (modified in place)
    action: MyAction,            // Action to handle
    dependencies: Dependencies   // Available services
) -> Effect<MyAction>           // Effect to run (or .none)
```

## State Updates

### Simple Updates
```swift
case .setName(let name):
    state.name = name
    return .none
```

### Array Updates
```swift
case .addItem(let item):
    state.items.append(item)
    return .none

case .removeItem(let id):
    state.items.removeAll { $0.id == id }
    return .none

case .toggleItem(let id):
    if let index = state.items.firstIndex(where: { $0.id == id }) {
        state.items[index].isCompleted.toggle()
    }
    return .none
```

### Complex Updates
```swift
case .updateUser(let user):
    state.user = user
    state.isAuthenticated = true
    state.lastLoginDate = dependencies.date()
    return .none
```

## Effects in Reducers

### No Effect
```swift
case .increment:
    state.count += 1
    return .none
```

### Send Action
```swift
case .reset:
    state.count = 0
    return .send(.dataSaved)
```

### Async Effect
```swift
case .loadData:
    state.isLoading = true
    return .task {
        let data = try await dependencies.dataService.loadData()
        return .dataLoaded(data)
    }
```

## Using Dependencies

Access services through the dependencies parameter:

```swift
case .createUser(let name):
    let user = User(
        id: dependencies.uuid(),
        name: name,
        createdAt: dependencies.date()
    )
    state.users.append(user)
    return .none
```

## Reducer Composition

### Combine Reducers
```swift
func appReducer(
    state: inout AppState,
    action: AppAction,
    dependencies: Dependencies
) -> Effect<AppAction> {
    let counterEffect = counterReducer(&state.counter, action, dependencies)
    let userEffect = userReducer(&state.user, action, dependencies)
    
    // Return the first non-none effect, or .none
    return counterEffect.isNone ? userEffect : counterEffect
}
```

### Action Filtering
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

## Best Practices

1. **Keep reducers pure** - no side effects, only state updates
2. **Handle all actions** - use exhaustive switch statements
3. **Use dependencies** for external services
4. **Return appropriate effects** - `.none` for simple updates
5. **Keep reducers focused** - one reducer per feature/domain

## Common Patterns

### Loading States
```swift
case .loadData:
    state.isLoading = true
    state.error = nil
    return .task {
        let data = try await dependencies.dataService.loadData()
        return .dataLoaded(data)
    }

case .dataLoaded(let data):
    state.data = data
    state.isLoading = false
    return .none

case .loadFailed(let error):
    state.error = error.localizedDescription
    state.isLoading = false
    return .none
```

### Form Handling
```swift
case .nameChanged(let name):
    state.name = name
    state.isValid = !name.isEmpty
    return .none

case .submit:
    guard state.isValid else { return .none }
    state.isSubmitting = true
    return .task {
        try await dependencies.userService.createUser(state.name)
        return .submitSucceeded
    }
```

## Next Steps

- [Effect](effect.md) - Learn about effects in detail
- [Store](store.md) - See how reducers work with stores
- [TestStore](teststore.md) - Test your reducers
