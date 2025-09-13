# WeatherApp Example

An advanced weather app that demonstrates real-world TCAKit patterns including network requests, error handling, loading states, effect cancellation, and complex state management.

## What This Example Teaches

- **Network Requests**: Making HTTP requests with proper error handling
- **Effect Cancellation**: Canceling in-flight requests when needed
- **Loading States**: Managing multiple loading states for different operations
- **Error Handling**: Comprehensive error handling with retry mechanisms
- **Real-world Dependencies**: Using external services and APIs
- **Complex State Management**: Managing multiple data sources and UI states
- **Location Services**: Handling location permissions and updates
- **Refresh Logic**: Pull-to-refresh and automatic refresh patterns

## The WeatherApp

This example creates a weather app with:
- **Current Weather**: Display current weather conditions
- **Forecast**: Show 5-day weather forecast
- **Location-based**: Get weather for current location
- **Search**: Search for weather in different cities
- **Refresh**: Pull-to-refresh and auto-refresh
- **Error Handling**: Network errors, location errors, API errors
- **Loading States**: Different loading indicators for different operations

## Code Walkthrough

### 1. Define the Models

```swift
struct WeatherData: Codable, Equatable {
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let location: String
}

struct ForecastItem: Codable, Equatable {
    let date: Date
    let temperature: Double
    let condition: String
}
```

### 2. Define the State

```swift
struct WeatherState {
    var currentWeather: WeatherData?
    var forecast: [ForecastItem] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var errorMessage: String?
    var locationPermission: LocationPermission = .notDetermined
}
```

### 3. Define the Actions

```swift
enum WeatherAction {
    case loadWeather
    case weatherLoaded(WeatherData)
    case loadForecast
    case forecastLoaded([ForecastItem])
    case searchTextChanged(String)
    case searchWeather
    case refreshWeather
    case cancelRequests
    case errorOccurred(String)
    case clearError
}
```

### 4. Handle Network Effects

```swift
case .loadWeather:
    state.isLoading = true
    return .task(
        operation: {
            let weather = try await dependencies.weatherService.getCurrentWeather()
            return .weatherLoaded(weather)
        },
        transform: WeatherAction.weatherLoaded
    )
    .cancellable(id: "weather", cancelInFlight: true)
```

### 5. Error Handling

```swift
case .errorOccurred(let message):
    state.errorMessage = message
    state.isLoading = false
    state.isRefreshing = false
    return .none
```

## Key TCAKit Patterns

### Effect Cancellation
- Use `.cancellable(id:)` to identify effects
- Use `.cancel(id:)` to cancel specific effects
- Use `cancelInFlight: true` to cancel previous requests

### Network Error Handling
- Handle different types of errors (network, parsing, API)
- Provide user-friendly error messages
- Implement retry mechanisms

### Loading State Management
- Different loading states for different operations
- Prevent multiple simultaneous requests
- Show appropriate loading indicators

### Dependency Injection
- Inject network services
- Use mock services for testing
- Handle service failures gracefully

## Running the Example

1. Copy the code from the WeatherApp files
2. Add TCAKit as a dependency to your project
3. Create a new SwiftUI view and paste the code
4. Run the app and try all the features!

## Features Demonstrated

### Weather Display
- Current weather with temperature, condition, humidity
- 5-day forecast with daily conditions
- Location-based weather data

### Search Functionality
- Search for weather in different cities
- Real-time search with debouncing
- Search history and suggestions

### Refresh Mechanisms
- Pull-to-refresh for current weather
- Auto-refresh every 5 minutes
- Manual refresh button

### Error Handling
- Network connectivity errors
- API rate limiting
- Invalid location errors
- Graceful error recovery

### Loading States
- Initial loading spinner
- Refresh indicator
- Search loading state
- Background refresh

## Advanced Patterns

### Effect Cancellation
```swift
case .cancelRequests:
    return .cancel(id: "weather")
        .merge(.cancel(id: "forecast"))
```

### Retry Logic
```swift
case .retryLoadWeather:
    return .task {
        try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
        return .loadWeather
    }
```

### Debounced Search
```swift
case .searchTextChanged(let text):
    state.searchText = text
    return .task {
        try await Task.sleep(nanoseconds: 500_000_000) // Wait 0.5 seconds
        return .searchWeather
    }
    .cancellable(id: "search")
```

## Next Steps

After understanding this example:
- Try adding more weather data (hourly forecast, weather maps)
- Implement location services for automatic location detection
- Add weather alerts and notifications
- Experiment with different UI layouts and animations

## Common Patterns

### Network Requests
```swift
case .loadData:
    return .task {
        let data = try await dependencies.service.getData()
        return .dataLoaded(data)
    }
    .cancellable(id: "load")
```

### Error Handling
```swift
case .errorOccurred(let error):
    state.errorMessage = error.localizedDescription
    state.isLoading = false
    return .none
```

### Loading States
```swift
case .startLoading:
    state.isLoading = true
    state.errorMessage = nil
    return .none
```

This example demonstrates how TCAKit handles complex, real-world applications with network requests, error handling, and sophisticated state management patterns.
