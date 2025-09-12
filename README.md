# TCAKit

A lightweight toolkit for The Composable Architecture (TCA) that provides utilities, extensions, and common patterns to enhance your TCA-based applications.

## Features

- 🚀 **Lightweight**: No external dependencies
- 🛠️ **Utilities**: Common TCA patterns and helpers
- 📱 **Cross-platform**: iOS, macOS, tvOS, and watchOS support
- ⚡ **Modern Swift**: Swift 5.9+ with Concurrency support
- 🔧 **Extensible**: Easy to add your own utilities

## Installation

### Swift Package Manager

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

## Usage

```swift
import TCAKit

// Access the version
print("TCAKit version: \(TCAKit.version)")

// Initialize TCAKit
let tcaKit = TCAKit()

// Use utilities
let patterns = TCAUtilities.Patterns.self
let extensions = TCAUtilities.Extensions.self
```

## Requirements

- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+
- Swift 5.9+
- Swift Concurrency support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Author

Created by [Amit Sen](https://github.com/ronstorm)

---

**Note**: This is a work in progress. More utilities and patterns will be added in future releases.
