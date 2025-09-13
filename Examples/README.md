# TCAKit Examples

This directory contains comprehensive, runnable examples that showcase TCAKit's capabilities. Each example is self-contained and demonstrates different aspects of the library.

## Examples Overview

### 🎯 [BasicCounter](./BasicCounter/)
**Perfect for beginners** - Learn the fundamentals of TCAKit with a simple counter app.

**What you'll learn:**
- Basic state management
- Action handling
- SwiftUI integration with `WithStore`
- Simple reducer patterns

### 📝 [TodoList](./TodoList/)
**Intermediate complexity** - Build a full-featured todo list with CRUD operations.

**What you'll learn:**
- Complex state management
- CRUD operations
- Effect handling with async operations
- Dependency injection
- Error handling
- Loading states

### 🌤️ [WeatherApp](./WeatherApp/)
**Advanced patterns** - Create a weather app with network requests and real-world scenarios.

**What you'll learn:**
- Network requests with effects
- Error handling and retry logic
- Loading and error states
- Dependency injection for services
- Effect cancellation
- Real-world app patterns

## Getting Started

### 🚀 **Quick Start (Recommended)**
- **[HOW_TO_RUN.md](HOW_TO_RUN.md)** - How to run the existing examples
- **[DEPENDENCY_SETUP.md](DEPENDENCY_SETUP.md)** - How to add TCAKit as a dependency

### 📚 **Detailed Learning**
1. **Choose an example** that matches your experience level
2. **Read the example's README** for detailed explanations
3. **Copy the code** into your own SwiftUI project
4. **Experiment** with modifications to understand the patterns

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- SwiftUI
- TCAKit (add as dependency)

## Adding TCAKit to Your Project

Add TCAKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ronstorm/tca-kit.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["TCAKit"]
)
```

## Example Structure

Each example follows this structure:
- `README.md` - Detailed explanation and step-by-step guide
- `ExampleName.swift` - Complete, runnable code
- `Models.swift` - Data models (if applicable)
- `Services.swift` - External services (if applicable)

## Contributing

Found an issue with an example? Have an idea for a new example? Please open an issue or submit a pull request!

## Support

- 📖 [Main Documentation](../README.md)
- 🐛 [Report Issues](https://github.com/ronstorm/tca-kit/issues)
- 💬 [Discussions](https://github.com/ronstorm/tca-kit/discussions)
