# TCAKit Setup Guide

Quick guide to get TCAKit examples running in your project.

## Add TCAKit Dependency

### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/ronstorm/tca-kit.git", from: "1.0.0")
]
```

### Xcode
1. File → Add Package Dependencies
2. URL: `https://github.com/ronstorm/tca-kit.git`
3. Add to your target

## Run Examples

### Option 1: Swift Playgrounds (Easiest)
1. Open Swift Playgrounds
2. Create new playground
3. Copy code from any example
4. Run immediately!

### Option 2: Xcode Project
1. Create new iOS project
2. Add TCAKit dependency (see above)
3. Copy example code into your project
4. Run (⌘+R)

## Example Files

- **BasicCounter**: Single file - copy `BasicCounter.swift`
- **TodoList**: Two files - copy `TodoList.swift` + `Models.swift`
- **WeatherApp**: Two files - copy `WeatherApp.swift` + `Models.swift`

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- SwiftUI

## Troubleshooting

**"No such module 'TCAKit'"**
- Make sure you added TCAKit as a dependency
- Check your target dependencies

**Build errors**
- Ensure you're using iOS 15.0+ and Swift 5.9+
- Check project deployment target

**App crashes on launch**
- Make sure you updated `App.swift` to use the correct app struct
- Check that all required files are copied

## Need More Help?

- [GitHub Issues](https://github.com/ronstorm/tca-kit/issues)
- [GitHub Discussions](https://github.com/ronstorm/tca-kit/discussions)
