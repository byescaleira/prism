import Foundation
import Testing

@testable import PrismArchitecture

// MARK: - Test Support

private struct TestState: PrismState, Equatable, Codable {
    var count: Int = 0
    var name: String = ""
}

private enum TestAction: Sendable {
    case increment
    case decrement
    case setName(String)
}

private final class LogBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _value = ""

    var value: String {
        lock.withLock { _value }
    }

    func append(_ string: String) {
        lock.withLock { _value = string }
    }
}

private final class ForwardBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _value = false

    var value: Bool {
        lock.withLock { _value }
    }

    func set() {
        lock.withLock { _value = true }
    }
}

// MARK: - Time Travel Tests

@Suite("PrismStateSnapshot")
@MainActor
struct PrismStateSnapshotTests {
    @Test("stores all properties")
    func snapshotStoresAllProperties() {
        let state = TestState(count: 42, name: "test")
        let date = Date()
        let snapshot = PrismStateSnapshot(
            state: state,
            action: "increment",
            timestamp: date,
            index: 3
        )

        #expect(snapshot.state == state)
        #expect(snapshot.action == "increment")
        #expect(snapshot.timestamp == date)
        #expect(snapshot.index == 3)
    }
}

@Suite("PrismTimeTravelDebugger")
@MainActor
struct PrismTimeTravelDebuggerTests {
    @Test("record adds snapshot")
    func recordAddsSnapshot() {
        let debugger = PrismTimeTravelDebugger<TestState>()
        let state = TestState(count: 1)

        debugger.record(state: state, action: "increment")

        #expect(debugger.snapshots.count == 1)
        #expect(debugger.currentIndex == 0)
        #expect(debugger.snapshots[0].state == state)
        #expect(debugger.snapshots[0].action == "increment")
    }

    @Test("goBack navigates to previous snapshot")
    func goBackNavigates() {
        let debugger = PrismTimeTravelDebugger<TestState>()

        debugger.record(state: TestState(count: 0), action: "initial")
        debugger.record(state: TestState(count: 1), action: "increment")
        debugger.record(state: TestState(count: 2), action: "increment")

        #expect(debugger.canGoBack)

        let snapshot = debugger.goBack()

        #expect(snapshot?.state.count == 1)
        #expect(debugger.currentIndex == 1)
    }

    @Test("goForward navigates to next snapshot")
    func goForwardNavigates() {
        let debugger = PrismTimeTravelDebugger<TestState>()

        debugger.record(state: TestState(count: 0), action: "initial")
        debugger.record(state: TestState(count: 1), action: "increment")

        debugger.goBack()

        #expect(debugger.canGoForward)

        let snapshot = debugger.goForward()

        #expect(snapshot?.state.count == 1)
        #expect(debugger.currentIndex == 1)
    }

    @Test("jumpTo index navigates directly")
    func jumpToIndex() {
        let debugger = PrismTimeTravelDebugger<TestState>()

        debugger.record(state: TestState(count: 0), action: "s0")
        debugger.record(state: TestState(count: 1), action: "s1")
        debugger.record(state: TestState(count: 2), action: "s2")
        debugger.record(state: TestState(count: 3), action: "s3")

        let snapshot = debugger.jumpTo(index: 1)

        #expect(snapshot?.state.count == 1)
        #expect(debugger.currentIndex == 1)
    }

    @Test("jumpTo returns nil for invalid index")
    func jumpToInvalidIndex() {
        let debugger = PrismTimeTravelDebugger<TestState>()

        debugger.record(state: TestState(count: 0), action: "s0")

        #expect(debugger.jumpTo(index: -1) == nil)
        #expect(debugger.jumpTo(index: 5) == nil)
    }

    @Test("canGoBack is false when at start")
    func canGoBackAtStart() {
        let debugger = PrismTimeTravelDebugger<TestState>()

        debugger.record(state: TestState(), action: "initial")

        #expect(!debugger.canGoBack)
    }

    @Test("canGoForward is false when at end")
    func canGoForwardAtEnd() {
        let debugger = PrismTimeTravelDebugger<TestState>()

        debugger.record(state: TestState(), action: "initial")

        #expect(!debugger.canGoForward)
    }

    @Test("maxSnapshots evicts oldest entries")
    func maxSnapshotsEviction() {
        let debugger = PrismTimeTravelDebugger<TestState>(maxSnapshots: 3)

        debugger.record(state: TestState(count: 0), action: "s0")
        debugger.record(state: TestState(count: 1), action: "s1")
        debugger.record(state: TestState(count: 2), action: "s2")
        debugger.record(state: TestState(count: 3), action: "s3")

        #expect(debugger.snapshots.count == 3)
        #expect(debugger.snapshots.first?.state.count == 1)
    }
}

// MARK: - Persistence Tests

@Suite("PrismDiskPersistence")
@MainActor
struct PrismDiskPersistenceTests {
    @Test("save and load roundtrip")
    func saveLoadRoundtrip() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )

        let persistence = PrismDiskPersistence(directory: tempDir)
        let state = TestState(count: 42, name: "persisted")

        try persistence.save(state, key: "test_state")
        let loaded: TestState? = try persistence.load(key: "test_state")

        #expect(loaded == state)

        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("load returns nil for missing key")
    func loadMissingKeyReturnsNil() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )

        let persistence = PrismDiskPersistence(directory: tempDir)
        let loaded: TestState? = try persistence.load(key: "nonexistent")

        #expect(loaded == nil)

        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("clear removes persisted file")
    func clearRemovesFile() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )

        let persistence = PrismDiskPersistence(directory: tempDir)
        let state = TestState(count: 1)

        try persistence.save(state, key: "clearable")
        try persistence.clear(key: "clearable")

        let loaded: TestState? = try persistence.load(key: "clearable")
        #expect(loaded == nil)

        try? FileManager.default.removeItem(at: tempDir)
    }
}

@Suite("PrismUserDefaultsPersistence")
@MainActor
struct PrismUserDefaultsPersistenceTests {
    @Test("save and load roundtrip")
    func saveLoadRoundtrip() throws {
        let suiteName = "com.prism.test.\(UUID().uuidString)"
        let persistence = PrismUserDefaultsPersistence(suiteName: suiteName)
        let state = TestState(count: 7, name: "defaults")

        try persistence.save(state, key: "ud_state")
        let loaded: TestState? = try persistence.load(key: "ud_state")

        #expect(loaded == state)

        try? persistence.clear(key: "ud_state")
    }

    @Test("clear removes stored data")
    func clearRemovesData() throws {
        let suiteName = "com.prism.test.\(UUID().uuidString)"
        let persistence = PrismUserDefaultsPersistence(suiteName: suiteName)
        let state = TestState(count: 1)

        try persistence.save(state, key: "ud_clearable")
        try persistence.clear(key: "ud_clearable")

        let loaded: TestState? = try persistence.load(key: "ud_clearable")
        #expect(loaded == nil)
    }
}

@Suite("PrismKeychainPersistence")
@MainActor
struct PrismKeychainPersistenceTests {
    @Test("clear does not throw for missing key")
    func clearMissingKeyDoesNotThrow() throws {
        let persistence = PrismKeychainPersistence()

        // Should not throw even when key doesn't exist
        try persistence.clear(key: "nonexistent_keychain_\(UUID().uuidString)")
    }
}

// MARK: - Derived Store Tests

@Suite("PrismDerivedStore")
@MainActor
struct PrismDerivedStoreTests {
    @Test("transforms parent state to local value")
    func transformsState() {
        let parentState = TestState(count: 10, name: "hello")
        let derived = PrismDerivedStore(
            initialState: parentState,
            transform: { @MainActor @Sendable state in state.count }
        )

        #expect(derived.value == 10)
    }

    @Test("update changes value when different")
    func updateChangesValue() {
        let derived = PrismDerivedStore(
            initialState: TestState(count: 0),
            transform: { @MainActor @Sendable state in state.count }
        )

        derived.update(from: TestState(count: 5))

        #expect(derived.value == 5)
    }

    @Test("update skips notification when value is equal")
    func updateSkipsWhenEqual() {
        let derived = PrismDerivedStore(
            initialState: TestState(count: 3),
            transform: { @MainActor @Sendable state in state.count }
        )

        // Updating with same count should not change the value reference
        derived.update(from: TestState(count: 3, name: "changed"))

        #expect(derived.value == 3)
    }

    @Test("PrismStoreScope sends local actions")
    func storeScopeSendsActions() {
        var receivedAction: TestAction?

        let scope = PrismStoreScope<TestState, Int, TestAction>(
            parentState: TestState(count: 0),
            toLocalState: { @MainActor @Sendable state in state.count },
            sendAction: { @MainActor @Sendable action in receivedAction = action }
        )

        scope.send(.increment)

        #expect(scope.state == 0)
        if case .increment = receivedAction {
            // expected
        } else {
            #expect(Bool(false), "Expected .increment action")
        }
    }
}

// MARK: - Middleware Chain Tests

@Suite("PrismMiddlewareChain")
@MainActor
struct PrismMiddlewareChainTests {
    @Test("builds array of middlewares in order")
    func buildsArray() {
        let chain = PrismMiddlewareChain()
            .add(PrismLoggingMiddleware())
            .add(PrismThrottleMiddleware())

        let middlewares = chain.build()

        #expect(middlewares.count == 2)
        #expect(middlewares[0] is PrismLoggingMiddleware)
        #expect(middlewares[1] is PrismThrottleMiddleware)
    }

    @Test("empty chain builds empty array")
    func emptyChain() {
        let chain = PrismMiddlewareChain()

        #expect(chain.build().isEmpty)
    }

    @Test("PrismLoggingMiddleware conforms to PrismChainableMiddleware")
    func loggingMiddlewareExists() {
        let middleware = PrismLoggingMiddleware()
        let _: any PrismChainableMiddleware = middleware

        // Type check is enough — conformance verified at compile time
        #expect(Bool(true))
    }

    @Test("PrismThrottleMiddleware conforms to PrismChainableMiddleware")
    func throttleMiddlewareExists() {
        let middleware = PrismThrottleMiddleware()
        let _: any PrismChainableMiddleware = middleware

        #expect(Bool(true))
    }

    @Test("PrismLoggingMiddleware invokes logger and calls next")
    func loggingMiddlewareInvokesLogger() async {
        let logBox = LogBox()
        let middleware = PrismLoggingMiddleware { logBox.append($0) }
        let forwardBox = ForwardBox()

        await middleware.handle(
            state: TestState(),
            action: TestAction.increment,
            next: { @Sendable _ in forwardBox.set() }
        )

        #expect(logBox.value.contains("increment"))
        #expect(forwardBox.value)
    }
}

// MARK: - Undo/Redo Tests

@Suite("PrismUndoRedoStack")
@MainActor
struct PrismUndoRedoStackTests {
    @Test("push and undo returns previous state")
    func pushAndUndo() {
        let stack = PrismUndoRedoStack<TestState>()

        stack.push(TestState(count: 0))
        stack.push(TestState(count: 1))

        let undone = stack.undo()

        #expect(undone?.count == 1)
        #expect(stack.undoStack.count == 1)
    }

    @Test("redo after undo returns state")
    func redoAfterUndo() {
        let stack = PrismUndoRedoStack<TestState>()

        stack.push(TestState(count: 0))
        stack.push(TestState(count: 1))

        let undone = stack.undo()
        let redone = stack.redo()

        #expect(undone?.count == 1)
        #expect(redone?.count == 1)
        #expect(stack.undoStack.count == 2)
        #expect(stack.redoStack.isEmpty)
    }

    @Test("canUndo is true when undo stack has entries")
    func canUndoFlag() {
        let stack = PrismUndoRedoStack<TestState>()

        #expect(!stack.canUndo)

        stack.push(TestState(count: 0))

        #expect(stack.canUndo)
    }

    @Test("canRedo is true after undo")
    func canRedoFlag() {
        let stack = PrismUndoRedoStack<TestState>()

        #expect(!stack.canRedo)

        stack.push(TestState(count: 0))
        _ = stack.undo()

        #expect(stack.canRedo)
    }

    @Test("clear empties both stacks")
    func clearEmptiesBothStacks() {
        let stack = PrismUndoRedoStack<TestState>()

        stack.push(TestState(count: 0))
        stack.push(TestState(count: 1))
        _ = stack.undo()

        #expect(stack.canUndo)
        #expect(stack.canRedo)

        stack.clear()

        #expect(!stack.canUndo)
        #expect(!stack.canRedo)
        #expect(stack.undoStack.isEmpty)
        #expect(stack.redoStack.isEmpty)
    }

    @Test("push clears redo stack")
    func pushClearsRedoStack() {
        let stack = PrismUndoRedoStack<TestState>()

        stack.push(TestState(count: 0))
        stack.push(TestState(count: 1))
        _ = stack.undo()

        #expect(stack.canRedo)

        stack.push(TestState(count: 2))

        #expect(!stack.canRedo)
    }

    @Test("maxStackSize evicts oldest entries")
    func maxStackSizeEviction() {
        let stack = PrismUndoRedoStack<TestState>(maxStackSize: 3)

        stack.push(TestState(count: 0))
        stack.push(TestState(count: 1))
        stack.push(TestState(count: 2))
        stack.push(TestState(count: 3))

        #expect(stack.undoStack.count == 3)
        #expect(stack.undoStack.first?.count == 1)
    }

    @Test("undo returns nil when stack is empty")
    func undoReturnsNilWhenEmpty() {
        let stack = PrismUndoRedoStack<TestState>()

        #expect(stack.undo() == nil)
    }

    @Test("redo returns nil when stack is empty")
    func redoReturnsNilWhenEmpty() {
        let stack = PrismUndoRedoStack<TestState>()

        #expect(stack.redo() == nil)
    }
}
