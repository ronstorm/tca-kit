#!/bin/bash

# TCAKit Release Script
# Usage: ./scripts/release.sh v1.0.0

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "❌ Error: Version required"
    echo "Usage: ./scripts/release.sh v1.0.0"
    exit 1
fi

# Validate version format (vX.Y.Z)
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Error: Invalid version format. Use vX.Y.Z (e.g., v1.0.0)"
    exit 1
fi

echo "🚀 Starting release process for $VERSION..."

# Check if we're on master branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "master" ]; then
    echo "❌ Error: Must be on master branch. Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Error: Working directory is not clean. Commit or stash changes first."
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$VERSION$"; then
    echo "❌ Error: Tag $VERSION already exists"
    exit 1
fi

echo "✅ Pre-release checks passed"

# Run tests
echo "🧪 Running tests..."
swift test
if [ $? -ne 0 ]; then
    echo "❌ Error: Tests failed"
    exit 1
fi
echo "✅ Tests passed"

# Create and push tag
echo "🏷️  Creating tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"
git push origin "$VERSION"
echo "✅ Tag $VERSION created and pushed"

# Create GitHub release
echo "📝 Creating GitHub release..."
gh release create "$VERSION" \
    --title "TCAKit $VERSION" \
    --notes-file <(cat <<EOF
# TCAKit $VERSION

## What's New

This is the first stable release of TCAKit! 🎉

### ✨ Features

- **Store**: SwiftUI-first state management with @MainActor publishing
- **Reducer**: Pure functions for handling actions and updating state
- **Effect**: Async side effects with cancellation support
- **Dependencies**: Environment-based dependency injection
- **WithStore**: SwiftUI helper for ergonomic store usage
- **TestStore**: Testing utilities with fluent assertions
- **CombineBridge**: Seamless Combine integration

### 📚 Documentation

- Complete documentation in the `Docs/` folder
- Comprehensive examples in the `Examples/` folder
- Quick start guide and best practices

### 🎯 Examples

- **BasicCounter**: Simple counter app (perfect for beginners)
- **TodoList**: Full-featured todo list with CRUD operations
- **WeatherApp**: Advanced weather app with network requests

### 🛠️ Technical Details

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+ with Concurrency support
- No external dependencies
- MIT License

### 📖 Getting Started

```swift
dependencies: [
    .package(url: "https://github.com/ronstorm/tca-kit.git", from: "1.0.0")
]
```

See the [Documentation](https://github.com/ronstorm/tca-kit/tree/main/Docs) for detailed guides and examples.

---

**Full Changelog**: https://github.com/ronstorm/tca-kit/compare/initial-commit...$VERSION
EOF
)
echo "✅ GitHub release created"

echo "🎉 Release $VERSION completed successfully!"
echo ""
echo "Next steps:"
echo "1. Verify the release on GitHub: https://github.com/ronstorm/tca-kit/releases"
echo "2. Update any external documentation"
echo "3. Announce the release to the community"
