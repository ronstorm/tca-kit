//  TodoList.swift
//  TCAKit Examples
//
//  Created by Amit Sen on 2024-12-19.
//  © 2024 Coding With Amit. All rights reserved.

import SwiftUI
import TCAKit

// MARK: - State

/// The state for our todo list app
struct TodoListState {
    var todos: [Todo] = []
    var newTodoText: String = ""
    var filter: TodoFilter = .all
    var isLoading: Bool = false
    var errorMessage: String?
    
    /// Computed property for filtered todos
    var filteredTodos: [Todo] {
        switch filter {
        case .all:
            return todos
        case .active:
            return todos.filter { !$0.isCompleted }
        case .completed:
            return todos.filter { $0.isCompleted }
        }
    }
    
    /// Computed property for todo count by status
    var todoCounts: (total: Int, active: Int, completed: Int) {
        let total = todos.count
        let completed = todos.filter { $0.isCompleted }.count
        let active = total - completed
        return (total, active, completed)
    }
}

// MARK: - Actions

/// All possible actions in our todo list app
enum TodoListAction {
    case addTodo
    case newTodoTextChanged(String)
    case toggleTodo(UUID)
    case deleteTodo(UUID)
    case filterChanged(TodoFilter)
    case loadTodos
    case todosLoaded([Todo])
    case saveTodos
    case todosSaved
    case errorOccurred(String)
    case clearError
}

// MARK: - Reducer

/// The reducer handles actions and updates state
func todoListReducer(
    state: inout TodoListState,
    action: TodoListAction,
    dependencies: Dependencies
) -> Effect<TodoListAction> {
    switch action {
    case .addTodo:
        let text = state.newTodoText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return .none }
        
        let newTodo = Todo(text: text)
        state.todos.append(newTodo)
        state.newTodoText = ""
        
        // Auto-save after adding
        return .send(.saveTodos)
        
    case .newTodoTextChanged(let text):
        state.newTodoText = text
        return .none
        
    case .toggleTodo(let id):
        if let index = state.todos.firstIndex(where: { $0.id == id }) {
            state.todos[index].isCompleted.toggle()
            // Auto-save after toggling
            return .send(.saveTodos)
        }
        return .none
        
    case .deleteTodo(let id):
        state.todos.removeAll { $0.id == id }
        // Auto-save after deleting
        return .send(.saveTodos)
        
    case .filterChanged(let filter):
        state.filter = filter
        return .none
        
    case .loadTodos:
        state.isLoading = true
        state.errorMessage = nil
        return .task {
            do {
                let todos = try await dependencies.todoService.loadTodos()
                return .todosLoaded(todos)
            } catch {
                return .errorOccurred(error.localizedDescription)
            }
        }
        
    case .todosLoaded(let todos):
        state.todos = todos
        state.isLoading = false
        return .none
        
    case .saveTodos:
        return .task {
            do {
                try await dependencies.todoService.saveTodos(state.todos)
                return .todosSaved
            } catch {
                return .errorOccurred(error.localizedDescription)
            }
        }
        
    case .todosSaved:
        return .none
        
    case .errorOccurred(let message):
        state.errorMessage = message
        state.isLoading = false
        return .none
        
    case .clearError:
        state.errorMessage = nil
        return .none
    }
}

// MARK: - SwiftUI Views

/// The main todo list view
struct TodoListView: View {
    let store: Store<TodoListState, TodoListAction>
    
    var body: some View {
        WithStore(store) { store in
            NavigationView {
                VStack(spacing: 0) {
                    // Header with stats
                    headerView(store: store)
                    
                    // Filter picker
                    filterPicker(store: store)
                    
                    // Todo list
                    todoList(store: store)
                    
                    // Add todo input
                    addTodoInput(store: store)
                }
                .navigationTitle("TCAKit Todos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Load") {
                            store.send(.loadTodos)
                        }
                        .disabled(store.state.isLoading)
                    }
                }
                .alert("Error", isPresented: .constant(store.state.errorMessage != nil)) {
                    Button("OK") {
                        store.send(.clearError)
                    }
                } message: {
                    Text(store.state.errorMessage ?? "")
                }
            }
            .onAppear {
                store.send(.loadTodos)
            }
        }
    }
    
    @ViewBuilder
    private func headerView(store: Store<TodoListState, TodoListAction>) -> some View {
        let counts = store.state.todoCounts
        
        HStack {
            VStack(alignment: .leading) {
                Text("Total: \(counts.total)")
                Text("Active: \(counts.active)")
                Text("Completed: \(counts.completed)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Spacer()
            
            if store.state.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    @ViewBuilder
    private func filterPicker(store: Store<TodoListState, TodoListAction>) -> some View {
        Picker("Filter", selection: store.binding(
            get: \.filter,
            send: TodoListAction.filterChanged
        )) {
            ForEach(TodoFilter.allCases, id: \.self) { filter in
                Text(filter.displayName).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    @ViewBuilder
    private func todoList(store: Store<TodoListState, TodoListAction>) -> some View {
        if store.state.filteredTodos.isEmpty {
            VStack {
                Spacer()
                Text("No todos found")
                    .foregroundColor(.secondary)
                Spacer()
            }
        } else {
            List {
                ForEach(store.state.filteredTodos) { todo in
                    TodoRowView(todo: todo) { action in
                        store.send(action)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let todo = store.state.filteredTodos[index]
                        store.send(.deleteTodo(todo.id))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func addTodoInput(store: Store<TodoListState, TodoListAction>) -> some View {
        HStack {
            TextField("Add a new todo...", text: store.binding(
                get: \.newTodoText,
                send: TodoListAction.newTodoTextChanged
            ))
            .textFieldStyle(.roundedBorder)
            .onSubmit {
                store.send(.addTodo)
            }
            
            Button("Add") {
                store.send(.addTodo)
            }
            .disabled(store.state.newTodoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
}

/// Individual todo row view
struct TodoRowView: View {
    let todo: Todo
    let onAction: (TodoListAction) -> Void
    
    var body: some View {
        HStack {
            Button {
                onAction(.toggleTodo(todo.id))
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(todo.text)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                
                Text(todo.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

// MARK: - App Setup

/// The main app that creates the store and displays the todo list
struct TodoListApp: App {
    // Create dependencies with todo service
    private let dependencies: Dependencies
    private let store: Store<TodoListState, TodoListAction>
    
    init() {
        // Initialize dependencies with mock todo service
        self.dependencies = Dependencies.mock(
            todoService: MockTodoService()
        )
        
        // Initialize the store
        self.store = Store(
            initialState: TodoListState(),
            reducer: todoListReducer,
            dependencies: dependencies
        )
    }
    
    var body: some Scene {
        WindowGroup {
            TodoListView(store: store)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTodos = [
            Todo(text: "Learn TCAKit", isCompleted: true),
            Todo(text: "Build a todo app", isCompleted: false),
            Todo(text: "Add persistence", isCompleted: false)
        ]
        
        let store = Store(
            initialState: TodoListState(todos: sampleTodos),
            reducer: todoListReducer,
            dependencies: Dependencies.mock(todoService: MockTodoService())
        )
        
        TodoListView(store: store)
            .previewDisplayName("Todo List with Sample Data")
    }
}
#endif
