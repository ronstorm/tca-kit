//  WeatherApp.swift
//  TCAKit Examples
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import SwiftUI
import TCAKit

// MARK: - State

/// The state for our weather app
struct WeatherState {
    var currentWeather: WeatherData?
    var forecast: [ForecastItem] = []
    var searchText: String = ""
    var searchResults: [String] = []
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var isSearching: Bool = false
    var errorMessage: String?
    var locationPermission: LocationPermission = .notDetermined
    var lastUpdated: Date?
    
    /// Computed property for current location
    var currentLocation: String {
        return currentWeather?.location ?? "Unknown"
    }
    
    /// Computed property for temperature display
    var temperatureDisplay: String {
        guard let weather = currentWeather else { return "--°" }
        return "\(Int(weather.temperature))°"
    }
}

// MARK: - Actions

/// All possible actions in our weather app
enum WeatherAction {
    case loadWeather
    case loadWeatherForLocation(String)
    case weatherLoaded(WeatherData)
    case loadForecast
    case forecastLoaded([ForecastItem])
    case searchTextChanged(String)
    case searchWeather
    case searchResultsLoaded([String])
    case selectLocation(String)
    case refreshWeather
    case cancelRequests
    case errorOccurred(String)
    case clearError
    case locationPermissionChanged(LocationPermission)
}

// MARK: - Reducer

// MARK: - Dependencies Extension

extension Dependencies {
    /// Weather service dependency
    public var weatherService: WeatherServiceProtocol {
        get { self[WeatherServiceKey.self] }
        set { self[WeatherServiceKey.self] = newValue }
    }
}

/// Key for weather service in Dependencies
private struct WeatherServiceKey: DependencyKey {
    static let defaultValue: WeatherServiceProtocol = MockWeatherService()
}

/// Protocol for dependency keys
private protocol DependencyKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

/// Extension to make Dependencies subscriptable
extension Dependencies {
    fileprivate subscript<K: DependencyKey>(_ key: K.Type) -> K.Value {
        get {
            // In a real implementation, this would use a proper dependency container
            // For now, we'll use a simple approach with a static dictionary
            return key.defaultValue
        }
        set {
            // In a real implementation, this would store the value
            // For now, we'll ignore the setter
        }
    }
}

/// The reducer handles actions and updates state
func weatherReducer(
    state: inout WeatherState,
    action: WeatherAction,
    dependencies: Dependencies
) -> Effect<WeatherAction> {
    switch action {
    case .loadWeather:
        state.isLoading = true
        state.errorMessage = nil
        return .task(
            operation: {
                try await dependencies.weatherService.getCurrentWeather(for: nil)
            },
            transform: { weather in
                .weatherLoaded(weather)
            }
        )
        .cancellable(id: "weather", cancelInFlight: true)
        
    case .loadWeatherForLocation(let location):
        state.isLoading = true
        state.errorMessage = nil
        return .task(
            operation: {
                try await dependencies.weatherService.getCurrentWeather(for: location)
            },
            transform: { weather in
                .weatherLoaded(weather)
            }
        )
        .cancellable(id: "weather", cancelInFlight: true)
        
    case .weatherLoaded(let weather):
        state.currentWeather = weather
        state.isLoading = false
        state.isRefreshing = false
        state.lastUpdated = Date()
        // Auto-load forecast when weather is loaded
        return .send(.loadForecast)
        
    case .loadForecast:
        let location = state.currentWeather?.location
        return .task(
            operation: {
                try await dependencies.weatherService.getForecast(for: location)
            },
            transform: { forecast in
                .forecastLoaded(forecast)
            }
        )
        .cancellable(id: "forecast", cancelInFlight: true)
        
    case .forecastLoaded(let forecast):
        state.forecast = forecast
        return .none
        
    case .searchTextChanged(let text):
        state.searchText = text
        state.searchResults = []
        
        // Debounced search
        return .task(
            operation: {
                try await Task.sleep(nanoseconds: 500_000_000) // Wait 0.5 seconds
            },
            transform: { _ in
                .searchWeather
            }
        )
        .cancellable(id: "search")
        
    case .searchWeather:
        let query = state.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            state.searchResults = []
            return .none
        }
        
        state.isSearching = true
        return .task(
            operation: {
                try await dependencies.weatherService.searchLocations(query)
            },
            transform: { results in
                .searchResultsLoaded(results)
            }
        )
        .cancellable(id: "search", cancelInFlight: true)
        
    case .searchResultsLoaded(let results):
        state.searchResults = results
        state.isSearching = false
        return .none
        
    case .selectLocation(let location):
        state.searchText = location
        state.searchResults = []
        return .send(.loadWeatherForLocation(location))
        
    case .refreshWeather:
        state.isRefreshing = true
        return .send(.loadWeather)
        
    case .cancelRequests:
        return .cancel(id: "weather")
        
    case .errorOccurred(let message):
        state.errorMessage = message
        state.isLoading = false
        state.isRefreshing = false
        state.isSearching = false
        return .none
        
    case .clearError:
        state.errorMessage = nil
        return .none
        
    case .locationPermissionChanged(let permission):
        state.locationPermission = permission
        return .none
    }
}

// MARK: - Store Extensions

extension Store {
    /// Creates a binding that reads from state and sends actions
    func binding<Value>(
        get: @escaping (State) -> Value,
        send: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { get(self.state) },
            set: { self.send(send($0)) }
        )
    }
}

// MARK: - SwiftUI Views

/// The main weather view
struct WeatherView: View {
    let store: Store<WeatherState, WeatherAction>
    
    var body: some View {
        WithStore(store) { store in
            NavigationView {
                VStack(spacing: 0) {
                    // Search bar
                    searchBar(store: store)
                    
                    // Search results
                    if !store.state.searchResults.isEmpty {
                        searchResults(store: store)
                    }
                    
                    // Main content
                    if store.state.isLoading && store.state.currentWeather == nil {
                        loadingView()
                    } else if let weather = store.state.currentWeather {
                        weatherContent(store: store, weather: weather)
                    } else {
                        emptyState(store: store)
                    }
                }
                .navigationTitle("Weather")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            store.send(.refreshWeather)
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(store.state.isRefreshing)
                    }
                }
                .refreshable {
                    store.send(.refreshWeather)
                }
                .alert("Error", isPresented: .constant(store.state.errorMessage != nil)) {
                    Button("OK") {
                        store.send(.clearError)
                    }
                    Button("Retry") {
                        store.send(.loadWeather)
                    }
                } message: {
                    Text(store.state.errorMessage ?? "")
                }
            }
            .onAppear {
                store.send(.loadWeather)
            }
        }
    }
    
    @ViewBuilder
    private func searchBar(store: Store<WeatherState, WeatherAction>) -> some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Search location...", text: store.binding(
                    get: { $0.searchText },
                    send: WeatherAction.searchTextChanged
                ))
                .textFieldStyle(.roundedBorder)
                
                if store.state.isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Show hint about available locations
            if store.state.searchText.isEmpty && store.state.searchResults.isEmpty {
                Text("Try: New York, London, Tokyo, Paris, Berlin, Mumbai, Dubai, Los Angeles, Toronto, Sydney")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func searchResults(store: Store<WeatherState, WeatherAction>) -> some View {
        if !store.state.searchResults.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Search Results")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                List(store.state.searchResults, id: \.self) { location in
                    Button(action: {
                        store.send(.selectLocation(location))
                    }) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            Text(location)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxHeight: 200)
                .listStyle(PlainListStyle())
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func loadingView() -> some View {
        VStack {
            Spacer()
            ProgressView("Loading weather...")
                .scaleEffect(1.2)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func emptyState(store: Store<WeatherState, WeatherAction>) -> some View {
        VStack {
            Spacer()
            Image(systemName: "cloud.sun")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No weather data")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Search for a location or pull to refresh")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func weatherContent(store: Store<WeatherState, WeatherAction>, weather: WeatherData) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current weather
                currentWeatherCard(weather: weather, store: store)
                
                // Forecast
                if !store.state.forecast.isEmpty {
                    forecastSection(store: store)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func currentWeatherCard(weather: WeatherData, store: Store<WeatherState, WeatherAction>) -> some View {
        VStack(spacing: 16) {
            // Location and last updated
            HStack {
                VStack(alignment: .leading) {
                    Text(weather.location)
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let lastUpdated = store.state.lastUpdated {
                        Text("Updated \(lastUpdated, style: .relative) ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if store.state.isRefreshing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Temperature and condition
            VStack(spacing: 8) {
                Text(store.state.temperatureDisplay)
                    .font(.system(size: 72, weight: .thin))
                    .foregroundColor(.primary)
                
                Text(weather.condition)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Weather details
            HStack(spacing: 20) {
                WeatherDetailView(
                    icon: "humidity",
                    label: "Humidity",
                    value: "\(weather.humidity)%"
                )
                
                WeatherDetailView(
                    icon: "wind",
                    label: "Wind",
                    value: "\(Int(weather.windSpeed)) mph"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func forecastSection(store: Store<WeatherState, WeatherAction>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("5-Day Forecast")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.state.forecast, id: \.date) { item in
                        ForecastCardView(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

/// Weather detail view for humidity, wind, etc.
struct WeatherDetailView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Forecast card view
struct ForecastCardView: View {
    let item: ForecastItem
    
    var body: some View {
        VStack(spacing: 8) {
            Text(item.date, format: .dateTime.weekday(.abbreviated))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(Int(item.temperature))°")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(item.condition)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 80)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - App Setup

/// The main app that creates the store and displays the weather
@main
struct WeatherApp: App {
    // Create dependencies with weather service
    private let dependencies: Dependencies
    private let store: Store<WeatherState, WeatherAction>
    
    init() {
        // Initialize dependencies with mock weather service
        self.dependencies = Dependencies.mock()
        
        // Initialize the store
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

// MARK: - Preview

#if DEBUG
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleWeather = WeatherData(
            temperature: 22.0,
            condition: "Partly Cloudy",
            humidity: 65,
            windSpeed: 12.5,
            location: "New York, NY"
        )
        
        let sampleForecast = [
            ForecastItem(date: Date(), temperature: 24.0, condition: "Sunny", humidity: 60, windSpeed: 10.0),
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, temperature: 20.0, condition: "Cloudy", humidity: 70, windSpeed: 8.5)
        ]
        
        let store = Store(
            initialState: WeatherState(
                currentWeather: sampleWeather,
                forecast: sampleForecast,
                lastUpdated: Date()
            ),
            reducer: weatherReducer,
            dependencies: Dependencies.mock()
        )
        
        WeatherView(store: store)
            .previewDisplayName("Weather App with Sample Data")
    }
}
#endif
