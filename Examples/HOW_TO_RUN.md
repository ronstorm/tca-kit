# How to Run TCAKit Examples

This guide shows you how to run the TCAKit examples that are already in this folder.

## 🚀 Quick Start

### Option 1: Swift Playgrounds (Easiest)

1. **Open Swift Playgrounds** on your iPad or iPhone
2. **Create a new playground**
3. **Copy the code** from any example file (e.g., `BasicCounter/BasicCounter.swift`)
4. **Run it** - works immediately!

### Option 2: Xcode Project

1. **Create a new iOS project** in Xcode:
   - File → New → Project
   - Choose "iOS App"
   - Interface: SwiftUI
   - Name it "TCAKitDemo"

2. **Add TCAKit dependency**:
   - File → Add Package Dependencies
   - URL: `https://github.com/ronstorm/tca-kit.git`
   - Click "Add Package"

3. **Copy example code**:
   - Copy the content from any example file
   - Paste it into your `ContentView.swift`
   - Replace the default code

4. **Run the app** (⌘+R)

## 📱 Available Examples

### 🎯 BasicCounter
**File**: `BasicCounter/BasicCounter.swift`
- **What it does**: Simple counter with increment, decrement, and reset
- **Perfect for**: Learning TCAKit basics
- **Copy**: The entire content of `BasicCounter.swift`

### 📝 TodoList
**Files**: `TodoList/TodoList.swift` + `TodoList/Models.swift`
- **What it does**: Full todo list with CRUD operations
- **Perfect for**: Learning complex state management
- **Copy**: Both files into your project

### 🌤️ WeatherApp
**Files**: `WeatherApp/WeatherApp.swift` + `WeatherApp/Models.swift`
- **What it does**: Weather app with network requests
- **Perfect for**: Learning advanced patterns
- **Copy**: Both files into your project

## 🔧 Step-by-Step: Running BasicCounter

### In Swift Playgrounds:
1. Open Swift Playgrounds
2. Create new playground
3. Copy everything from `Examples/BasicCounter/BasicCounter.swift`
4. Paste and run

### In Xcode:
1. Create new iOS project
2. Add TCAKit dependency
3. Replace `ContentView.swift` with content from `BasicCounter.swift`
4. Run (⌘+R)

## 🔧 Step-by-Step: Running TodoList

### In Xcode:
1. Create new iOS project
2. Add TCAKit dependency
3. Create two new files:
   - `TodoModels.swift` (copy from `TodoList/Models.swift`)
   - `TodoList.swift` (copy from `TodoList/TodoList.swift`)
4. Update `App.swift`:
   ```swift
   import SwiftUI
   
   @main
   struct MyApp: App {
       var body: some Scene {
           WindowGroup {
               TodoListApp()
           }
       }
   }
   ```
5. Run (⌘+R)

## 🔧 Step-by-Step: Running WeatherApp

### In Xcode:
1. Create new iOS project
2. Add TCAKit dependency
3. Create two new files:
   - `WeatherModels.swift` (copy from `WeatherApp/Models.swift`)
   - `WeatherApp.swift` (copy from `WeatherApp/WeatherApp.swift`)
4. Update `App.swift`:
   ```swift
   import SwiftUI
   
   @main
   struct MyApp: App {
       var body: some Scene {
           WindowGroup {
               WeatherApp()
           }
       }
   }
   ```
5. Run (⌘+R)

## 🎯 Which Example Should I Start With?

### 🎯 **BasicCounter** (Recommended First)
- **Why**: Simplest example, perfect for learning basics
- **What you'll learn**: State, actions, reducers, SwiftUI integration
- **Time**: 5 minutes to run

### 📝 **TodoList** (Intermediate)
- **Why**: Real-world patterns, more complex state
- **What you'll learn**: CRUD operations, effects, dependencies
- **Time**: 10 minutes to run

### 🌤️ **WeatherApp** (Advanced)
- **Why**: Production-ready patterns, network requests
- **What you'll learn**: Error handling, loading states, effect cancellation
- **Time**: 15 minutes to run

## 🚨 Troubleshooting

### "No such module 'TCAKit'"
- **Solution**: Make sure you added TCAKit as a dependency
- **Check**: File → Add Package Dependencies → URL: `https://github.com/ronstorm/tca-kit.git`

### Build errors
- **Solution**: Make sure you're using iOS 15.0+ and Swift 5.9+
- **Check**: Project settings → Deployment Target

### "Cannot find 'CounterState' in scope"
- **Solution**: Make sure you copied ALL the code from the example file
- **Check**: All structs, enums, and functions are included

### App crashes on launch
- **Solution**: Make sure you updated `App.swift` to use the correct app struct
- **Check**: `CounterApp()`, `TodoListApp()`, or `WeatherApp()`

## 💡 Pro Tips

1. **Start with BasicCounter** - it's the simplest
2. **Read the README** in each example folder for detailed explanations
3. **Use Swift Playgrounds** for quick experiments
4. **Copy the entire file** - don't miss any code
5. **Check the file structure** - some examples need multiple files

## 🆘 Need Help?

- 📖 **Read the README** in each example folder
- 🐛 **Report issues**: [GitHub Issues](https://github.com/ronstorm/tca-kit/issues)
- 💬 **Ask questions**: [GitHub Discussions](https://github.com/ronstorm/tca-kit/discussions)

---

**Ready to start?** Pick an example, copy the code, and run it! 🚀
