# Effect

Effects represent async side effects in TCAKit. They handle operations like network requests, timers, and other asynchronous work.

## Overview

Effects:
- Represent async operations
- Can be cancelled
- Return actions when complete
- Run outside the main thread

## Basic Effects

### No Effect
Return `.none` when no side effect is needed:

```swift
case .increment:
    state.count += 1
    return .none
```

### Send Action
Send a single action:

```swift
case .reset:
    state.count = 0
    return .send(.dataLoaded)
```

## Async Effects

### Task Effect
Run async operations:

```swift
case .loadData:
    return .task {
        let data = try await loadDataFromAPI()
        return .dataLoaded(data)
    }
```

### Task with Transform
Transform the result:

```swift
case .loadUsers:
    return .task(
        operation: {
            try await userService.loadUsers()
        },
        transform: { users in
            .usersLoaded(users)
        }
    )
```

## Effect Cancellation

### Cancellable Effects
Make effects cancellable:

```swift
case .loadData:
    return .task {
        let data = try await loadDataFromAPI()
        return .dataLoaded(data)
    }
    .cancellable(id: "load-data")
```

### Cancel Effects
Cancel specific effects:

```swift
case .cancelLoad:
    return .cancel(id: "load-data")
```

### Cancel In-Flight
Cancel previous effects:

```swift
case .loadData:
    return .task {
        let data = try await loadDataFromAPI()
        return .dataLoaded(data)
    }
    .cancellable(id: "load-data", cancelInFlight: true)
```

## Effect Sequences

Send multiple actions:

```swift
case .loadAllData:
    return .sequence([
        .send(.loadUsers),
        .send(.loadPosts),
        .send(.loadComments)
    ])
```

## Error Handling

Handle errors in effects:

```swift
case .loadData:
    return .task {
        do {
            let data = try await loadDataFromAPI()
            return .dataLoaded(data)
        } catch {
            return .loadFailed(error.localizedDescription)
        }
    }
```

## Real Examples

### Network Request
```swift
case .loadWeather:
    state.isLoading = true
    return .task {
        let weather = try await dependencies.weatherService.getCurrentWeather()
        return .weatherLoaded(weather)
    }
    .cancellable(id: "weather", cancelInFlight: true)
```

### Debounced Search
```swift
case .searchTextChanged(let text):
    state.searchText = text
    return .task {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return .performSearch
    }
    .cancellable(id: "search")
```

## Best Practices

1. **Use `.task`** for async operations
2. **Add cancellation IDs** for effects that can be cancelled
3. **Handle errors** appropriately
4. **Use `cancelInFlight: true`** for search/refresh operations
5. **Keep effects focused** - one effect per action when possible

## Next Steps

- [Store](store.md) - Learn how stores manage effects
- [Dependencies](dependencies.md) - Inject services into effects
- [TestStore](teststore.md) - Test effects and their outcomes
