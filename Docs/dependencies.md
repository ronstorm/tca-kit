# Dependencies

TCAKit provides a built-in `Dependencies` container for dependency injection. You can extend it to add your own services.

## Overview

Dependencies allow you to:
- Inject services into your reducers
- Swap implementations for testing
- Keep business logic separate from external services
- Make your code more testable and modular

## Built-in Dependencies

TCAKit provides these dependencies out of the box:

```swift
let dependencies = Dependencies()

// Current date
let now = dependencies.date()

// Generate UUIDs
let id = dependencies.uuid()

// HTTP requests
let data = try await dependencies.httpClient(url)
```

## Extending Dependencies

### 1. Define Your Service Protocol

```swift
protocol UserServiceProtocol {
    func loadUsers() async throws -> [User]
    func saveUser(_ user: User) async throws
}
```

### 2. Extend Dependencies

```swift
extension Dependencies {
    public var userService: UserServiceProtocol {
        get { self[UserServiceKey.self] }
        set { self[UserServiceKey.self] = newValue }
    }
}
```

### 3. Create a Dependency Key

```swift
private struct UserServiceKey: DependencyKey {
    static let defaultValue: UserServiceProtocol = MockUserService()
}
```

### 4. Use in Your Reducer

```swift
func userReducer(
    state: inout UserState,
    action: UserAction,
    dependencies: Dependencies
) -> Effect<UserAction> {
    switch action {
    case .loadUsers:
        return .task {
            let users = try await dependencies.userService.loadUsers()
            return .usersLoaded(users)
        }
    }
}
```

### 5. Configure in Your App

```swift
let dependencies = Dependencies().with(\.userService, RealUserService())
let store = Store(
    initialState: UserState(),
    reducer: userReducer,
    dependencies: dependencies
)
```

## Testing

### Test Dependencies
Use predictable values for testing:

```swift
let testDependencies = Dependencies.test
// Uses fixed date, UUID, and test HTTP client
```

### Mock Dependencies
Create custom test implementations:

```swift
let mockDependencies = Dependencies.mock(
    date: { Date(timeIntervalSince1970: 0) },
    httpClient: { _ in Data("test data".utf8) }
)
```

### Custom Service Testing
Inject mock services for testing:

```swift
let testDependencies = Dependencies()
    .with(\.userService, MockUserService())
```

## Best Practices

1. **Define protocols** for your services
2. **Use dependency keys** for type-safe injection
3. **Provide default implementations** (usually mocks)
4. **Inject real services** in production
5. **Use test dependencies** in tests

## Real Examples

See how dependencies are used in the examples:
- **[TodoList](../Examples/TodoList/)** - Shows `TodoService` extension
- **[WeatherApp](../Examples/WeatherApp/)** - Shows `WeatherService` extension

## Next Steps

- [Effect](effect.md) - Learn about async effects
- [TestStore](teststore.md) - Comprehensive testing strategies
- [Examples](../Examples/) - See dependencies in action
