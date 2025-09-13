# WeatherApp Example

An advanced weather app demonstrating real-world TCAKit patterns.

## What You'll Learn

- **Network Requests**: Making HTTP requests with proper error handling
- **Effect Cancellation**: Canceling in-flight requests
- **Loading States**: Managing multiple loading states
- **Error Handling**: Comprehensive error handling with retry
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
        let weather = try await dependencies.weatherService.getCurrentWeather()
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
```

## Running

1. Copy both `WeatherApp.swift` and `Models.swift`
2. Add TCAKit as a dependency
3. Run the app!

## Advanced Patterns

This example demonstrates production-ready patterns including network requests, effect cancellation, error handling, and complex state management.