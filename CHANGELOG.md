# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Store Core Implementation (B-002)**
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
- **Comprehensive Testing**
  - 17 test cases covering all core functionality
  - Store initialization and action handling tests
  - Effect execution and chaining tests
  - Reducer utility tests
  - Store scoping functionality tests
- **Documentation & Examples**
  - Updated README with practical usage examples
  - Counter example showing basic TCA patterns
  - Effect example demonstrating async operations
  - SwiftUI integration examples

### Changed
- Updated README to reflect new Store core functionality
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
