import Foundation

/// A typed event that can be published and subscribed to.
public protocol PrismEvent: Sendable {
    /// Unique event name. Defaults to type name.
    static var name: String { get }
}

extension PrismEvent {
    public static var name: String { String(describing: Self.self) }
}

/// Actor-based publish/subscribe event bus.
public actor PrismEventBus {
    private var listeners: [String: [EventListener]] = [:]
    private var nextID: Int = 0

    public init() {}

    /// Subscribes to an event type. Returns a listener ID for unsubscription.
    @discardableResult
    public func on<E: PrismEvent>(_ type: E.Type, handler: @escaping @Sendable (E) async -> Void) -> Int {
        let id = nextID
        nextID += 1
        let listener = EventListener(id: id) { event in
            if let typed = event as? E {
                await handler(typed)
            }
        }
        listeners[E.name, default: []].append(listener)
        return id
    }

    /// Subscribes to an event type for one-time delivery.
    public func once<E: PrismEvent>(_ type: E.Type, handler: @escaping @Sendable (E) async -> Void) {
        let busRef = self
        let id = on(type) { event in
            await handler(event)
            await busRef.off(id: -1) // placeholder — actual removal below
        }
        // Re-register with correct self-removing behavior
        listeners[E.name]?.removeAll { $0.id == id }
        let selfRemovingListener = EventListener(id: id) { event in
            if let typed = event as? E {
                await handler(typed)
                await busRef.removeListener(id: id, eventName: E.name)
            }
        }
        listeners[E.name, default: []].append(selfRemovingListener)
    }

    /// Publishes an event to all listeners.
    public func emit<E: PrismEvent>(_ event: E) async {
        guard let eventListeners = listeners[E.name] else { return }
        for listener in eventListeners {
            await listener.handle(event)
        }
    }

    /// Removes a specific listener by ID.
    public func off(id: Int) {
        for key in listeners.keys {
            listeners[key]?.removeAll { $0.id == id }
        }
    }

    /// Removes all listeners for an event type.
    public func removeAll<E: PrismEvent>(for type: E.Type) {
        listeners.removeValue(forKey: E.name)
    }

    /// Returns the number of listeners for an event type.
    public func listenerCount<E: PrismEvent>(for type: E.Type) -> Int {
        listeners[E.name]?.count ?? 0
    }

    fileprivate func removeListener(id: Int, eventName: String) {
        listeners[eventName]?.removeAll { $0.id == id }
    }
}

private struct EventListener: Sendable {
    let id: Int
    let handle: @Sendable (any Sendable) async -> Void

    init(id: Int, handle: @escaping @Sendable (any Sendable) async -> Void) {
        self.id = id
        self.handle = handle
    }
}

// MARK: - Built-in Server Events

/// Emitted when the server starts.
public struct PrismServerStarted: PrismEvent {
    public let port: UInt16
    public let host: String
    public init(port: UInt16, host: String) { self.port = port; self.host = host }
}

/// Emitted when the server stops.
public struct PrismServerStopped: PrismEvent {
    public init() {}
}

/// Emitted for each completed request.
public struct PrismRequestCompleted: PrismEvent {
    public let method: String
    public let path: String
    public let statusCode: Int
    public let duration: Duration
    public init(method: String, path: String, statusCode: Int, duration: Duration) {
        self.method = method
        self.path = path
        self.statusCode = statusCode
        self.duration = duration
    }
}

/// Emitted when an unhandled error occurs.
public struct PrismServerError: PrismEvent {
    public let error: String
    public let path: String?
    public init(error: String, path: String? = nil) {
        self.error = error
        self.path = path
    }
}
