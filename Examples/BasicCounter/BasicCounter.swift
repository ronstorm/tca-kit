//  BasicCounter.swift
//  TCAKit Examples
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import SwiftUI
import TCAKit

// MARK: - State

/// The state for our counter app
struct CounterState {
    var count: Int = 0
}

// MARK: - Actions

/// All possible actions in our counter app
enum CounterAction {
    case increment
    case decrement
    case reset
}

// MARK: - Reducer

/// The reducer handles actions and updates state
func counterReducer(
    state: inout CounterState,
    action: CounterAction,
    dependencies: Dependencies
) -> Effect<CounterAction> {
    switch action {
    case .increment:
        state.count += 1
    case .decrement:
        state.count -= 1
    case .reset:
        state.count = 0
    }
    return .none
}

// MARK: - SwiftUI View

/// The main counter view
struct CounterView: View {
    let store: Store<CounterState, CounterAction>
    
    var body: some View {
        WithStore(store) { store in
            VStack(spacing: 20) {
                // Display current count
                Text("Count: \(store.state.count)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("−") {
                        store.send(.decrement)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("Reset") {
                        store.send(.reset)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("+") {
                        store.send(.increment)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                
                // Additional info
                Text("Tap the buttons to change the count")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

// MARK: - App Setup

/// The main app that creates the store and displays the counter
struct CounterApp: App {
    // Create dependencies and store
    private let dependencies = Dependencies()
    private let store: Store<CounterState, CounterAction>
    
    init() {
        // Initialize the store with our reducer
        self.store = Store(
            initialState: CounterState(),
            reducer: counterReducer,
            dependencies: dependencies
        )
    }
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: store)
                .navigationTitle("TCAKit Counter")
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: CounterState(count: 5),
            reducer: counterReducer,
            dependencies: Dependencies()
        )
        
        CounterView(store: store)
            .previewDisplayName("Counter with count 5")
    }
}
#endif
