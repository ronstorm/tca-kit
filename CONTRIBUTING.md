# Contributing to TCAKit

Thank you for your interest in contributing to TCAKit! We welcome contributions from the community and are grateful for your help in making this project better.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Issue Guidelines](#issue-guidelines)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [me@amitsen.de](mailto:me@amitsen.de).

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- Swift 5.9 or later
- macOS 12.0 or later (for development)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/tca-kit.git
   cd tca-kit
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/ronstorm/tca-kit.git
   ```

## How to Contribute

### Types of Contributions

We welcome several types of contributions:

- **Bug fixes**: Fix issues and improve stability
- **New features**: Add new functionality (please discuss first)
- **Documentation**: Improve docs, examples, and guides
- **Tests**: Add or improve test coverage
- **Performance**: Optimize existing code
- **Examples**: Create new example apps

### Before You Start

1. **Check existing issues**: Look for similar issues or feature requests
2. **Discuss major changes**: Open an issue to discuss significant changes
3. **Check the roadmap**: See what's planned in the [project issues](https://github.com/ronstorm/tca-kit/issues)

## Development Setup

### 1. Open the Project

```bash
open Package.swift
```

### 2. Run Tests

```bash
swift test
```

### 3. Build Examples

```bash
# Build all examples
swift build

# Run a specific example
cd Examples/BasicCounter
swift run
```

### 4. Lint Code

```bash
swiftlint lint
```

## Coding Standards

### Swift Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 2 spaces for indentation
- Maximum line length: 120 characters
- Use `swiftlint` to enforce style (configuration in `.swiftlint.yml`)

### Code Organization

- Keep files under 300 lines
- Use clear, descriptive names
- Add documentation for public APIs
- Group related functionality together

### Architecture Principles

- **Keep it simple**: Prefer simple solutions over complex ones
- **Testable**: Write code that's easy to test
- **SwiftUI-first**: Optimize for SwiftUI usage patterns
- **Zero dependencies**: Avoid external dependencies

## Testing

### Test Requirements

- All new features must include tests
- Bug fixes must include regression tests
- Maintain or improve test coverage
- Tests must pass on all supported platforms

### Writing Tests

```swift
import XCTest
@testable import TCAKit

final class StoreTests: XCTestCase {
    func testStoreInitialization() async throws {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer,
            dependencies: Dependencies()
        )
        
        XCTAssertEqual(store.state.value, 0)
    }
}
```

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter StoreTests.testStoreInitialization
```

## Documentation

### Code Documentation

- Document all public APIs with doc comments
- Include usage examples in documentation
- Keep documentation up to date with code changes

### Example Documentation

```swift
/// A lightweight state management solution for SwiftUI.
///
/// TCAKit provides a simple, testable way to manage state in SwiftUI applications
/// using the patterns from The Composable Architecture.
///
/// ## Basic Usage
///
/// ```swift
/// let store = Store(
///     initialState: CounterState(),
///     reducer: counterReducer,
///     dependencies: Dependencies()
/// )
/// ```
public final class Store<State: Sendable, Action: Sendable>: ObservableObject {
    // ...
}
```

### README Updates

- Update README.md for significant changes
- Add new examples to the Examples section
- Update installation instructions if needed

## Pull Request Process

### Before Submitting

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Write code following our standards
   - Add tests for new functionality
   - Update documentation as needed

3. **Test your changes**:
   ```bash
   swift test
   swiftlint lint
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

### Submitting a PR

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request**:
   - Use a clear, descriptive title
   - Reference any related issues
   - Include a detailed description

3. **PR Template**:
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Performance improvement
   - [ ] Other (please describe)

   ## Testing
   - [ ] Tests pass locally
   - [ ] New tests added for new functionality
   - [ ] All examples still work

   ## Checklist
   - [ ] Code follows project style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] No breaking changes (or clearly documented)
   ```

### Review Process

- All PRs require review before merging
- Address feedback promptly
- Keep PRs focused and reasonably sized
- Update PR description if changes are made

## Issue Guidelines

### Bug Reports

When reporting bugs, please include:

- **Description**: Clear description of the issue
- **Steps to Reproduce**: Detailed steps to reproduce
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**: OS, Xcode version, Swift version
- **Code Sample**: Minimal code that reproduces the issue

### Feature Requests

When requesting features, please include:

- **Use Case**: Why is this feature needed?
- **Proposed Solution**: How should it work?
- **Alternatives**: Other solutions you've considered
- **Additional Context**: Any other relevant information

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped in Package.swift
- [ ] Release notes prepared
- [ ] Tag created and pushed

## Community

### Getting Help

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussion
- **Email**: [opensource@ronstorm.dev](mailto:opensource@ronstorm.dev)

### Recognition

Contributors will be recognized in:
- Release notes
- README.md contributors section
- GitHub contributors page

## Thank You

Thank you for contributing to TCAKit! Your contributions help make this project better for everyone in the SwiftUI community.

---

**Questions?** Feel free to reach out to [me@amitsen.de](mailto:me@amitsen.de) or open a GitHub issue.
