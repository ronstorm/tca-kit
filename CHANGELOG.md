# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Store Core Implementation**
  - `Store<State, Action>` class with @MainActor publishing
  - ObservableObject conformance for SwiftUI integration
  - Action dispatching with `send(_:)` method
  - State observation through `@Published` property
  - Store scoping for child views with `scope(state:action:)`
  - Simple store creation with `Store.simple(initialState:reduce:)`
- **Effect System**
  - `Effect<Action>` struct for async side effects
  - Async/await support with cancellation
  - Effect builders: `.none`, `.send()`, `.task()`, `.sequence()`
  - Error handling for throwing operations
- **Reducer System**
  - `Reducer<State, Action>` type alias for pure functions
  - Reducer utilities: `combine()`, `forAction()`, `transform()`
  - State mutation through `inout` parameters
- **Dependencies System**
  - `Dependencies` struct for environment-based dependency injection
  - Built-in services: `date()`, `uuid()`, `httpClient()`
  - Test helpers: `Dependencies.test` and `Dependencies.mock()`
  - Immutable updates with `.with()` method
  - No singleton pattern - explicit dependency injection
- **Cancellation Helpers**
  - `Effect.cancellable(id:cancelInFlight:)` to identify and optionally cancel in-flight work
  - `Effect.cancel(id:)` to explicitly cancel effects by identifier
  - Store-managed in-flight task tracking keyed by cancellation ID
- **Scoping API**
  - `Store.scope(state:action:)` for child stores (state/action mapping)
  - New overload: `Store.scope(state:action:toLocalAction:)` maps parent effect outputs back to local actions
  - Tests covering effect mapping through scoped stores
- **SwiftUI Helpers**
  - `WithStore` view wrapper for ergonomic store usage in SwiftUI
  - Automatic store observation and lifecycle management
  - Scoped store support with `WithStore(store, state:action:content:)`
  - Store extension method `store.withStore(content:)`
  - Better testing with explicit store injection
- **Comprehensive Testing**
  - 20 test cases covering all core functionality
  - Store initialization and action handling tests
  - Effect execution and chaining tests
  - Cancellation behavior tests (cancel-in-flight, metadata)
  - Reducer utility tests
  - Store scoping functionality tests
- **Documentation & Examples**
  - Updated README with practical usage examples
  - Added cancellation usage examples and guidance
  - Counter example showing basic TCA patterns
  - Effect example demonstrating async operations
  - SwiftUI integration examples

### Changed
- Updated README to reflect new Store core functionality
- Updated Effect and Store to support identifier-based cancellation
- Enhanced TCAKit.swift with comprehensive usage documentation

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

## [1.0.0] - 2024-12-19

### Added
- Initial release of TCAKit
- Lightweight toolkit for The Composable Architecture
- Cross-platform support (iOS 15+, macOS 12+, tvOS 15+, watchOS 8+)
- Swift 5.9+ and Concurrency support
- No external dependencies
- Basic API structure with TCAKit and TCAUtilities
- Comprehensive .gitignore for Swift projects
- MIT License
- README with installation and usage instructions

### Features
- 🚀 Lightweight with no external dependencies
- 🛠️ Utilities for common TCA patterns and helpers
- 📱 Cross-platform support
- ⚡ Modern Swift with Concurrency support
- 🔧 Extensible architecture

---

**Note**: This changelog follows the [Keep a Changelog](https://keepachangelog.com/) format and uses [Semantic Versioning](https://semver.org/).
