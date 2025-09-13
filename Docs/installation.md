# Installation

Add TCAKit to your Swift project using Swift Package Manager.

## Swift Package Manager

Add TCAKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ronstorm/tca-kit.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [.product(name: "TCAKit", package: "tca-kit")]
)
```

## Xcode

1. **File → Add Package Dependencies**
2. **Enter URL**: `https://github.com/ronstorm/tca-kit.git`
3. **Select version**: Latest or specific version
4. **Add to target**: Your app target

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- SwiftUI

## Next Steps

- [Basic Usage](basic-usage.md) - Create your first TCAKit app
- [Examples](../Examples/) - Try the ready-to-run examples
