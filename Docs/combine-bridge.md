# CombineBridge

`CombineBridge` provides seamless integration between Combine publishers and TCAKit effects. It allows you to easily convert Combine publishers into TCAKit effects and vice versa, making it simple to integrate existing Combine-based code with TCAKit.

## Basic Usage

```swift
import TCAKit
import Combine

// Convert a Combine publisher to a TCAKit effect
let publisher = URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: User.self, decoder: JSONDecoder())

let effect = publisher
    .map(Action.userLoaded)
    .catch { _ in Just(Action.userLoadFailed) }
    .eraseToEffect()
```

## Converting Publishers to Effects

### Simple Publisher Conversion

```swift
func loadUserEffect(id: String) -> Effect<UserAction> {
    return userService
        .loadUser(id: id)
        .map(UserAction.userLoaded)
        .catch { error in
            Just(UserAction.userLoadFailed(error))
        }
        .eraseToEffect()
}
```

### Publisher with Error Handling

```swift
func searchEffect(query: String) -> Effect<SearchAction> {
    return searchService
        .search(query: query)
        .map(SearchAction.resultsReceived)
        .catch { error in
            Just(SearchAction.searchFailed(error))
        }
        .eraseToEffect()
}
```

## Converting Effects to Publishers

### Effect to Publisher

```swift
func createPublisher(from effect: Effect<Action>) -> AnyPublisher<Action, Never> {
    return effect
        .asPublisher()
        .eraseToAnyPublisher()
}
```

### Using in Combine Chains

```swift
let searchPublisher = searchService
    .search(query: query)
    .flatMap { results in
        // Convert TCAKit effect to publisher
        processResultsEffect(results)
            .asPublisher()
    }
    .eraseToAnyPublisher()
```

## Advanced Patterns

### Debounced Search

```swift
func debouncedSearchEffect(query: String) -> Effect<SearchAction> {
    return Just(query)
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .flatMap { query in
            searchService.search(query: query)
                .map(SearchAction.resultsReceived)
                .catch { error in
                    Just(SearchAction.searchFailed(error))
                }
        }
        .eraseToEffect()
}
```

### Retry Logic

```swift
func retryableEffect() -> Effect<DataAction> {
    return dataService
        .loadData()
        .retry(3)
        .map(DataAction.dataLoaded)
        .catch { error in
            Just(DataAction.dataLoadFailed(error))
        }
        .eraseToEffect()
}
```

### Combining Multiple Publishers

```swift
func combinedEffect() -> Effect<AppAction> {
    return Publishers.CombineLatest(
        userService.loadUser(),
        settingsService.loadSettings()
    )
    .map { user, settings in
        AppAction.dataLoaded(user: user, settings: settings)
    }
    .catch { error in
        Just(AppAction.dataLoadFailed(error))
    }
    .eraseToEffect()
}
```

## Integration with Dependencies

### Service Integration

```swift
struct DataService {
    func loadData() -> AnyPublisher<Data, Error> {
        // Your existing Combine-based service
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Data.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// In your reducer
func dataReducer(
    state: inout DataState,
    action: DataAction,
    dependencies: Dependencies
) -> Effect<DataAction> {
    switch action {
    case .loadData:
        return dependencies.dataService
            .loadData()
            .map(DataAction.dataLoaded)
            .catch { error in
                Just(DataAction.dataLoadFailed(error))
            }
            .eraseToEffect()
    }
}
```

## Testing with CombineBridge

### Testing Publisher Effects

```swift
func testDataLoading() {
    let mockService = MockDataService()
    let store = TestStore(
        initialState: DataState(),
        reducer: dataReducer,
        dependencies: Dependencies()
            .with(\.dataService, mockService)
    )
    
    store.send(.loadData) {
        $0.isLoading = true
    }
    
    store.receive(.dataLoaded(mockData)) {
        $0.isLoading = false
        $0.data = mockData
    }
}
```

### Mock Publisher Services

```swift
class MockDataService: DataService {
    var loadDataCalled = false
    
    func loadData() -> AnyPublisher<Data, Error> {
        loadDataCalled = true
        return Just(mockData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
```

## Best Practices

1. **Use `eraseToEffect()`** - Always erase the type when converting to effects
2. **Handle errors properly** - Use `catch` to convert errors to actions
3. **Keep publishers focused** - One publisher per logical operation
4. **Test with mocks** - Use mock services for testing
5. **Leverage Combine operators** - Use debounce, retry, etc. as needed

## Common Use Cases

### Network Requests

```swift
func networkEffect(url: URL) -> Effect<NetworkAction> {
    return URLSession.shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: Response.self, decoder: JSONDecoder())
        .map(NetworkAction.responseReceived)
        .catch { error in
            Just(NetworkAction.requestFailed(error))
        }
        .eraseToEffect()
}
```

### Timer Effects

```swift
func timerEffect() -> Effect<TimerAction> {
    return Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .map { _ in TimerAction.tick }
        .eraseToEffect()
}
```

### Location Updates

```swift
func locationEffect() -> Effect<LocationAction> {
    return locationManager
        .locationPublisher
        .map(LocationAction.locationUpdated)
        .catch { error in
            Just(LocationAction.locationError(error))
        }
        .eraseToEffect()
}
```

`CombineBridge` makes it easy to integrate TCAKit with existing Combine-based code, providing a smooth migration path and powerful composition capabilities.
