# TestStore

`TestStore` is a testing utility that provides fluent assertions and transcripts for testing TCAKit reducers and effects. It allows you to verify state changes and effect outputs in a declarative way.

## Basic Usage

```swift
import TCAKit
import XCTest

class CounterTests: XCTestCase {
    func testIncrement() {
        let store = TestStore(
            initialState: CounterState(count: 0),
            reducer: counterReducer,
            dependencies: Dependencies()
        )
        
        store.send(.increment) {
            $0.count = 1
        }
    }
}
```

## State Assertions

TestStore allows you to assert state changes using a closure:

```swift
func testCounterActions() {
    let store = TestStore(
        initialState: CounterState(count: 0),
        reducer: counterReducer,
        dependencies: Dependencies()
    )
    
    // Test increment
    store.send(.increment) {
        $0.count = 1
    }
    
    // Test decrement
    store.send(.decrement) {
        $0.count = 0
    }
    
    // Test reset
    store.send(.reset) {
        $0.count = 0
    }
}
```

## Effect Testing

TestStore can also verify that effects are returned and executed:

```swift
func testLoadDataEffect() {
    let store = TestStore(
        initialState: DataState(isLoading: false),
        reducer: dataReducer,
        dependencies: Dependencies()
    )
    
    store.send(.loadData) {
        $0.isLoading = true
    }
    
    // Verify effect was returned
    store.receive(.dataLoaded(.success(mockData))) {
        $0.isLoading = false
        $0.data = mockData
    }
}
```

## Dependency Testing

You can override dependencies for testing:

```swift
func testWithMockDependencies() {
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
    
    // Verify mock service was called
    XCTAssertTrue(mockService.loadDataCalled)
}
```

## Advanced Testing Patterns

### Testing Complex State

```swift
func testComplexStateUpdate() {
    let store = TestStore(
        initialState: AppState(
            user: nil,
            todos: [],
            isLoading: false
        ),
        reducer: appReducer,
        dependencies: Dependencies()
    )
    
    store.send(.loginUser(credentials)) {
        $0.isLoading = true
    }
    
    store.receive(.userLoggedIn(user)) {
        $0.user = user
        $0.isLoading = false
    }
    
    store.send(.loadTodos) {
        $0.isLoading = true
    }
    
    store.receive(.todosLoaded(todos)) {
        $0.todos = todos
        $0.isLoading = false
    }
}
```

### Testing Effect Cancellation

```swift
func testEffectCancellation() {
    let store = TestStore(
        initialState: SearchState(),
        reducer: searchReducer,
        dependencies: Dependencies()
    )
    
    store.send(.search("query")) {
        $0.isSearching = true
    }
    
    // Cancel the search
    store.send(.cancelSearch) {
        $0.isSearching = false
    }
    
    // Verify no results received after cancellation
    store.finish()
}
```

## Best Practices

1. **Use descriptive test names** - Make it clear what behavior you're testing
2. **Test one thing at a time** - Keep tests focused and simple
3. **Use mock dependencies** - Isolate your tests from external services
4. **Verify both state and effects** - Test the complete behavior
5. **Use `store.finish()`** - Ensure all effects complete in async tests

## Common Patterns

### Testing Loading States

```swift
func testLoadingState() {
    let store = TestStore(
        initialState: DataState(),
        reducer: dataReducer,
        dependencies: Dependencies()
    )
    
    store.send(.loadData) {
        $0.isLoading = true
    }
    
    store.receive(.dataLoaded(.success(data))) {
        $0.isLoading = false
        $0.data = data
    }
}
```

### Testing Error Handling

```swift
func testErrorHandling() {
    let store = TestStore(
        initialState: DataState(),
        reducer: dataReducer,
        dependencies: Dependencies()
    )
    
    store.send(.loadData) {
        $0.isLoading = true
    }
    
    store.receive(.dataLoaded(.failure(error))) {
        $0.isLoading = false
        $0.error = error
    }
}
```

`TestStore` makes testing TCAKit code straightforward and reliable, ensuring your state management logic works correctly.
