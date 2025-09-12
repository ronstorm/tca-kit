//  TestHelpers.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Foundation
@testable import TCAKit

// Test helper for creating simple reducers that ignore dependencies
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
func simpleReducer<State, Action>(
    _ reducer: @escaping (inout State, Action) -> Effect<Action>
) -> Reducer<State, Action> {
    return { state, action, _ in
        reducer(&state, action)
    }
}
