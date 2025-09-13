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

### Option 1: Standalone Apps (Easiest)
All examples are complete, runnable apps with `@main` attribute:

1. **Copy the example files** to your project
2. **Add TCAKit dependency** (see above)
3. **Run immediately!** (⌘+R)

### Option 2: Swift Playgrounds
1. Open Swift Playgrounds
2. Create new playground
3. Copy code from any example
4. Run immediately!

### Option 3: Integration into Existing App
1. Copy example code into your existing project
2. Add TCAKit dependency (see above)
3. Update your `App.swift` to use the example's app struct
4. Run (⌘+R)

## Example Files

- **BasicCounter**: Single file - copy `BasicCounter.swift` (standalone app)
- **TodoList**: Two files - copy `TodoList.swift` + `Models.swift` (standalone app)
- **WeatherApp**: Two files - copy `WeatherApp.swift` + `Models.swift` (standalone app)

## Important Notes

- **All examples are standalone apps** with `@main` attribute - they can run independently
- **TodoList and WeatherApp** use mock services for demonstration (no real network calls)
- **Dependencies are pre-configured** - no additional setup needed for the examples

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
