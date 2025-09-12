# Contributing to TCAKit

Thank you for your interest in contributing to TCAKit! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project and everyone participating in it is governed by our commitment to providing a welcoming and inclusive environment. By participating, you agree to:

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what's best for the community
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/tca-kit.git
   cd tca-kit
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/ronstorm/tca-kit.git
   ```

## Development Setup

### Prerequisites

- Swift 5.9+
- Xcode 15+ (for iOS/macOS development)
- Git
- SwiftLint (optional, for code quality)

### CI/CD

This project uses GitHub Actions for continuous integration and deployment:

- **CI Pipeline**: Runs on every push and pull request
- **Code Quality**: SwiftLint, security scans, and dependency checks
- **Testing**: Multi-platform testing (iOS, macOS, tvOS, watchOS)
- **Documentation**: Automatic documentation generation
- **Releases**: Automated releases with proper tagging
- **Dependencies**: Automated dependency updates

### Building the Project

```bash
# Build the package
swift build

# Run tests
swift test

# Build for release
swift build -c release

# Run SwiftLint (if installed)
swiftlint
```

### Running Tests

```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose
```

## Contributing Guidelines

### Types of Contributions

We welcome several types of contributions:

- **Bug fixes**: Fix issues and improve stability
- **New features**: Add new utilities and patterns
- **Documentation**: Improve README, code comments, and examples
- **Tests**: Add test coverage for new or existing features
- **Performance improvements**: Optimize existing code
- **Examples**: Add usage examples and tutorials

### Before You Start

1. **Check existing issues** to see if your contribution is already being worked on
2. **Open an issue** for significant changes to discuss the approach
3. **Keep changes focused** - one feature or fix per pull request

## Pull Request Process

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 2. Make Your Changes

- Write clean, well-documented code
- Add tests for new functionality
- Update documentation as needed
- Follow the coding standards below

### 3. Commit Your Changes

Use conventional commit messages:

```bash
git commit -m "feat: add new TCA utility for state management"
git commit -m "fix: resolve memory leak in reducer"
git commit -m "docs: update README with new examples"
```

**Commit Message Format:**
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `chore:` - Maintenance tasks

### 4. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub with:
- Clear title and description
- Reference any related issues
- Include screenshots for UI changes
- List any breaking changes

## Issue Reporting

### Bug Reports

When reporting bugs, please include:

- **Swift version** and **platform** (iOS/macOS/tvOS/watchOS)
- **Steps to reproduce** the issue
- **Expected behavior** vs **actual behavior**
- **Code sample** that demonstrates the issue
- **Screenshots** if applicable

### Feature Requests

For feature requests, please include:

- **Use case** and **motivation**
- **Proposed solution** or approach
- **Alternatives** you've considered
- **Additional context** or examples

## Coding Standards

### Swift Style Guide

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use **2-space indentation**
- Prefer **trailing commas** in multi-line collections
- Use **meaningful names** for variables and functions
- Add **doc comments** for public APIs
- Run **SwiftLint** to ensure code quality (see `.swiftlint.yml` configuration)

### Code Organization

```swift
// 1. File header (already included)
// 2. Imports
import Foundation

// 3. Public types and protocols
public struct TCAKit {
    // 4. Public properties
    public static let version = "1.0.0"
    
    // 5. Public methods
    public init() {}
}

// 6. Private types and extensions
private extension TCAKit {
    // Private implementation
}
```

### Documentation

- Add **doc comments** for all public APIs
- Include **usage examples** in documentation
- Update **README.md** for significant changes
- Update **CHANGELOG.md** for new features or fixes

## Testing

### Test Requirements

- **All new features** must include tests
- **Bug fixes** should include regression tests
- **Maintain or improve** test coverage
- **Use descriptive test names**

### Test Structure

```swift
@Test func testFeatureName() async throws {
    // Arrange
    let input = "test input"
    
    // Act
    let result = TCAKit.process(input)
    
    // Assert
    #expect(result == "expected output")
}
```

## Documentation

### Code Documentation

- Use **triple-slash comments** for public APIs
- Include **parameter descriptions**
- Provide **usage examples**
- Document **throwing methods** and **preconditions**

### README Updates

- Update **installation instructions** if needed
- Add **new usage examples**
- Update **requirements** for new features
- Keep **feature list** current

## Release Process

1. **Update version** in `Package.swift` and `TCAKit.swift`
2. **Update CHANGELOG.md** with new features and fixes
3. **Create release tag** on GitHub
4. **Update documentation** as needed

## Questions?

If you have questions about contributing:

- **Open an issue** for general questions
- **Start a discussion** for feature ideas
- **Check existing issues** for similar questions

## Thank You

Thank you for contributing to TCAKit! Your contributions help make this toolkit better for the entire TCA community.

---

**Happy coding!** 🚀
