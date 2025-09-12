//  TestStoreTests.swift
//  tca-kit
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import Testing
import Foundation
@testable import TCAKit

// MARK: - Test Models

struct TestCounterState: Equatable {
    var count: Int = 0
    var message: String = ""
}

enum TestCounterAction: Equatable {
    case increment
    case decrement
    case reset
    case setMessage(String)
    case setCount(Int)
}

// MARK: - TestStore Tests

struct TestStoreTests {

    @Test func testBasicSendAction() async throws {
        let testStore = await TestStore<TestCounterState, TestCounterAction>(
            initialState: TestCounterState(count: 0),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setMessage(let message):
                    state.message = message
                case .setCount(let count):
                    state.count = count
                }
                return .none
            },
            dependencies: Dependencies.test
        )

        let transcript = await testStore
            .send(.increment) { state in
                state.count = 1
            }
            .finish()

        #expect(transcript.steps.count == 1)
        #expect(transcript.steps[0].type == .send)
        #expect(transcript.steps[0].action == .increment)
    }

    @Test func testMultipleSendActions() async throws {
        let testStore = await TestStore<TestCounterState, TestCounterAction>(
            initialState: TestCounterState(count: 0),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setMessage(let message):
                    state.message = message
                case .setCount(let count):
                    state.count = count
                }
                return .none
            },
            dependencies: Dependencies.test
        )

        let transcript = await testStore
            .send(.increment) { state in
                state.count = 1
            }
            .send(.increment) { state in
                state.count = 2
            }
            .send(.decrement) { state in
                state.count = 1
            }
            .finish()

        #expect(transcript.steps.count == 3)
        #expect(transcript.steps[0].action == .increment)
        #expect(transcript.steps[1].action == .increment)
        #expect(transcript.steps[2].action == .decrement)
    }

    @Test func testReceiveAction() async throws {
        let testStore = await TestStore<TestCounterState, TestCounterAction>(
            initialState: TestCounterState(count: 0, message: ""),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setMessage(let message):
                    state.message = message
                case .setCount(let count):
                    state.count = count
                }
                return .none
            },
            dependencies: Dependencies.test
        )

        let transcript = await testStore
            .send(.setMessage("Hello")) { state in
                state.message = "Hello"
            }
            .receive(.setCount(42)) { state in
                state.count = 42
            }
            .finish()

        #expect(transcript.steps.count == 2)
        #expect(transcript.steps[0].type == .send)
        #expect(transcript.steps[0].action == .setMessage("Hello"))
        #expect(transcript.steps[1].type == .receive)
        #expect(transcript.steps[1].action == .setCount(42))
    }

    @Test func testTranscriptDescription() async throws {
        let testStore = await TestStore<TestCounterState, TestCounterAction>(
            initialState: TestCounterState(count: 0),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setMessage(let message):
                    state.message = message
                case .setCount(let count):
                    state.count = count
                }
                return .none
            },
            dependencies: Dependencies.test
        )

        let transcript = await testStore
            .send(.increment) { state in
                state.count = 1
            }
            .send(.setMessage("Hello")) { state in
                state.message = "Hello"
            }
            .finish()

        let description = transcript.description
        #expect(description.contains("Test Transcript:"))
        #expect(description.contains("Send increment"))
        #expect(description.contains("Send setMessage"))
    }

    @Test func testCurrentStateAccess() async throws {
        let testStore = await TestStore<TestCounterState, TestCounterAction>(
            initialState: TestCounterState(count: 0),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setMessage(let message):
                    state.message = message
                case .setCount(let count):
                    state.count = count
                }
                return .none
            },
            dependencies: Dependencies.test
        )

        #expect(testStore.state.count == 0)

        await testStore.send(.increment) { state in
            state.count = 1
        }

        #expect(testStore.state.count == 1)

        await testStore.send(.setCount(42)) { state in
            state.count = 42
        }

        #expect(testStore.state.count == 42)
    }

    @Test func testCurrentTranscriptAccess() async throws {
        let testStore = await TestStore<TestCounterState, TestCounterAction>(
            initialState: TestCounterState(count: 0),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setMessage(let message):
                    state.message = message
                case .setCount(let count):
                    state.count = count
                }
                return .none
            },
            dependencies: Dependencies.test
        )

        #expect(testStore.currentTranscript.steps.isEmpty)

        await testStore.send(.increment) { state in
            state.count = 1
        }

        #expect(testStore.currentTranscript.steps.count == 1)

        await testStore.send(.decrement) { state in
            state.count = 0
        }

        #expect(testStore.currentTranscript.steps.count == 2)
    }

    @Test func testStepTimestamps() async throws {
        let testStore = await TestStore<TestCounterState, TestCounterAction>(
            initialState: TestCounterState(count: 0),
            reducer: { state, action, _ in
                switch action {
                case .increment:
                    state.count += 1
                case .decrement:
                    state.count -= 1
                case .reset:
                    state.count = 0
                case .setMessage(let message):
                    state.message = message
                case .setCount(let count):
                    state.count = count
                }
                return .none
            },
            dependencies: Dependencies.test
        )

        let startTime = Date()

        let transcript = await testStore
            .send(.increment) { state in
                state.count = 1
            }
            .send(.increment) { state in
                state.count = 2
            }
            .finish()

        let endTime = Date()

        #expect(transcript.steps.count == 2)
        #expect(transcript.steps[0].timestamp >= startTime)
        #expect(transcript.steps[0].timestamp <= endTime)
        #expect(transcript.steps[1].timestamp >= startTime)
        #expect(transcript.steps[1].timestamp <= endTime)
        #expect(transcript.steps[1].timestamp >= transcript.steps[0].timestamp)
    }
}
