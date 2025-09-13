# WeatherApp Example

An advanced weather app demonstrating real-world TCAKit patterns.

## What You'll Learn

- **Network Requests**: Making HTTP requests with proper error handling
- **Effect Cancellation**: Canceling in-flight requests
- **Loading States**: Managing multiple loading states
- **Error Handling**: Comprehensive error handling with retry
- **Extending Dependencies**: How to add custom services to TCAKit's Dependencies
- **Real-world Dependencies**: Using external services and APIs
- **Complex State Management**: Managing multiple data sources

## Features

- **Current Weather**: Display current weather conditions
- **Forecast**: Show 5-day weather forecast
- **Search**: Search for weather in different cities
- **Refresh**: Pull-to-refresh and auto-refresh
- **Error Handling**: Network errors, API errors
- **Loading States**: Different loading indicators

## Key Patterns

```swift
// Network Effects with Cancellation
case .loadWeather:
    state.isLoading = true
    return .task {
        let weather = try await dependencies.weatherService.getCurrentWeather(for: nil)
        return .weatherLoaded(weather)
    }
    .cancellable(id: "weather", cancelInFlight: true)

// Effect Cancellation
case .cancelRequests:
    return .cancel(id: "weather")
        .merge(.cancel(id: "forecast"))

// Error Handling
case .errorOccurred(let message):
    state.errorMessage = message
    state.isLoading = false
    return .none

// Extending Dependencies
extension Dependencies {
    public var weatherService: WeatherServiceProtocol {
        get { self[WeatherServiceKey.self] }
        set { self[WeatherServiceKey.self] = newValue }
    }
}

private struct WeatherServiceKey: DependencyKey {
    static let defaultValue: WeatherServiceProtocol = MockWeatherService()
}

// Complete App (standalone)
@main
struct WeatherApp: App {
    private let dependencies: Dependencies
    private let store: Store<WeatherState, WeatherAction>
    
    init() {
        // Mock service for demonstration
        self.dependencies = Dependencies.mock()
        self.store = Store(
            initialState: WeatherState(),
            reducer: weatherReducer,
            dependencies: dependencies
        )
    }
    
    var body: some Scene {
        WindowGroup {
            WeatherView(store: store)
        }
    }
}
```

## Running

**Option 1: Standalone App (Easiest)**
1. Copy both `WeatherApp.swift` and `Models.swift` to your project
2. Add TCAKit as a dependency
3. Run immediately! (⌘+R)

**Option 2: Integration**
1. Copy both files into your existing app
2. Add TCAKit as a dependency
3. Update your `App.swift` to use `WeatherApp()`

**Note**: Uses `MockWeatherService` for demonstration - no real network calls needed!

## Advanced Patterns

This example demonstrates production-ready patterns including network requests, effect cancellation, error handling, and complex state management.