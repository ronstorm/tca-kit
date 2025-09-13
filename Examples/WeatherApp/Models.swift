//  Models.swift
//  TCAKit Examples
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation

// MARK: - Weather Models

/// Represents current weather data
public struct WeatherData: Codable, Equatable {
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let location: String
    let timestamp: Date
    
    public init(
        temperature: Double,
        condition: String,
        humidity: Int,
        windSpeed: Double,
        location: String,
        timestamp: Date = Date()
    ) {
        self.temperature = temperature
        self.condition = condition
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.location = location
        self.timestamp = timestamp
    }
}

/// Represents a forecast item
public struct ForecastItem: Codable, Equatable {
    let date: Date
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    
    public init(
        date: Date,
        temperature: Double,
        condition: String,
        humidity: Int,
        windSpeed: Double
    ) {
        self.date = date
        self.temperature = temperature
        self.condition = condition
        self.humidity = humidity
        self.windSpeed = windSpeed
    }
}

/// Location permission status
enum LocationPermission: String, CaseIterable {
    case notDetermined = "Not Determined"
    case denied = "Denied"
    case authorized = "Authorized"
    case restricted = "Restricted"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Weather Service Protocol

/// Protocol for weather data operations
public protocol WeatherServiceProtocol {
    func getCurrentWeather(for location: String?) async throws -> WeatherData
    func getForecast(for location: String?) async throws -> [ForecastItem]
    func searchLocations(_ query: String) async throws -> [String]
}

// MARK: - Mock Weather Service

/// Mock implementation of WeatherService for demonstration
public struct MockWeatherService: WeatherServiceProtocol {
    private let sampleWeatherData: [String: WeatherData] = [
        "New York": WeatherData(
            temperature: 22.0,
            condition: "Partly Cloudy",
            humidity: 65,
            windSpeed: 12.5,
            location: "New York, NY"
        ),
        "London": WeatherData(
            temperature: 15.0,
            condition: "Rainy",
            humidity: 80,
            windSpeed: 8.2,
            location: "London, UK"
        ),
        "Tokyo": WeatherData(
            temperature: 28.0,
            condition: "Sunny",
            humidity: 55,
            windSpeed: 5.1,
            location: "Tokyo, Japan"
        ),
        "Sydney": WeatherData(
            temperature: 25.0,
            condition: "Cloudy",
            humidity: 70,
            windSpeed: 15.3,
            location: "Sydney, Australia"
        ),
        "Paris": WeatherData(
            temperature: 18.0,
            condition: "Overcast",
            humidity: 75,
            windSpeed: 6.8,
            location: "Paris, France"
        ),
        "Berlin": WeatherData(
            temperature: 16.0,
            condition: "Light Rain",
            humidity: 85,
            windSpeed: 9.2,
            location: "Berlin, Germany"
        ),
        "Mumbai": WeatherData(
            temperature: 32.0,
            condition: "Hot and Humid",
            humidity: 90,
            windSpeed: 4.5,
            location: "Mumbai, India"
        ),
        "Dubai": WeatherData(
            temperature: 35.0,
            condition: "Very Hot",
            humidity: 45,
            windSpeed: 8.0,
            location: "Dubai, UAE"
        ),
        "Los Angeles": WeatherData(
            temperature: 24.0,
            condition: "Sunny",
            humidity: 40,
            windSpeed: 7.5,
            location: "Los Angeles, CA"
        ),
        "Toronto": WeatherData(
            temperature: 12.0,
            condition: "Cold",
            humidity: 60,
            windSpeed: 11.0,
            location: "Toronto, Canada"
        )
    ]
    
    private let sampleForecastData: [String: [ForecastItem]] = [
        "New York": [
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, temperature: 24.0, condition: "Sunny", humidity: 60, windSpeed: 10.0),
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, temperature: 20.0, condition: "Cloudy", humidity: 70, windSpeed: 8.5),
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, temperature: 18.0, condition: "Rainy", humidity: 85, windSpeed: 12.0),
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, temperature: 26.0, condition: "Sunny", humidity: 55, windSpeed: 6.0),
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, temperature: 23.0, condition: "Partly Cloudy", humidity: 65, windSpeed: 9.0)
        ],
        "London": [
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, temperature: 16.0, condition: "Rainy", humidity: 85, windSpeed: 12.0),
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, temperature: 14.0, condition: "Cloudy", humidity: 80, windSpeed: 10.0),
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, temperature: 17.0, condition: "Partly Cloudy", humidity: 70, windSpeed: 8.0),
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, temperature: 19.0, condition: "Sunny", humidity: 60, windSpeed: 6.0),
            ForecastItem(date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, temperature: 15.0, condition: "Rainy", humidity: 75, windSpeed: 11.0)
        ]
    ]
    
    public func getCurrentWeather(for location: String? = nil) async throws -> WeatherData {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        
        // Simulate occasional network errors (15% chance)
        if Int.random(in: 1...100) <= 15 {
            throw WeatherServiceError.networkError("Failed to fetch weather data")
        }
        
        let searchLocation = location ?? "New York"
        
        // Find matching location (case-insensitive)
        let matchingLocation = sampleWeatherData.keys.first { key in
            key.lowercased().contains(searchLocation.lowercased())
        }
        
        guard let locationKey = matchingLocation,
              let weather = sampleWeatherData[locationKey] else {
            throw WeatherServiceError.locationNotFound("Location '\(searchLocation)' not found")
        }
        
        return weather
    }
    
    public func getForecast(for location: String? = nil) async throws -> [ForecastItem] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        // Simulate occasional network errors (10% chance)
        if Int.random(in: 1...100) <= 10 {
            throw WeatherServiceError.networkError("Failed to fetch forecast data")
        }
        
        let searchLocation = location ?? "New York"
        
        // Find matching location (case-insensitive)
        let matchingLocation = sampleForecastData.keys.first { key in
            key.lowercased().contains(searchLocation.lowercased())
        }
        
        guard let locationKey = matchingLocation,
              let forecast = sampleForecastData[locationKey] else {
            throw WeatherServiceError.locationNotFound("Location '\(searchLocation)' not found")
        }
        
        return forecast
    }
    
    public func searchLocations(_ query: String) async throws -> [String] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Remove random errors for better testing experience
        // if Int.random(in: 1...100) <= 5 {
        //     throw WeatherServiceError.networkError("Failed to search locations")
        // }
        
        let allLocations = Array(sampleWeatherData.keys)
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // If query is empty, return all locations
        if trimmedQuery.isEmpty {
            return allLocations
        }
        
        // More flexible search - matches any part of the location name
        return allLocations.filter { location in
            location.lowercased().contains(trimmedQuery)
        }
    }
}

// MARK: - Weather Service Error

/// Errors that can occur in weather operations
public enum WeatherServiceError: LocalizedError {
    case networkError(String)
    case locationNotFound(String)
    case invalidAPIKey
    case rateLimitExceeded
    case parsingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .locationNotFound(let message):
            return "Location Error: \(message)"
        case .invalidAPIKey:
            return "Invalid API Key: Please check your weather service configuration"
        case .rateLimitExceeded:
            return "Rate Limit Exceeded: Too many requests. Please try again later."
        case .parsingError(let message):
            return "Data Error: \(message)"
        }
    }
}
