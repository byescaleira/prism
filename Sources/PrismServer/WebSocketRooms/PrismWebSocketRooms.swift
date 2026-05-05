import Foundation

/// A named room/channel that groups WebSocket connections.
public actor PrismRoom {
    /// The room's unique name identifier.
    public nonisolated let name: String
    private var connections: [String: PrismWebSocketConnection] = [:]

    /// Creates a new `PrismRoom` with the specified configuration.
    public init(name: String) {
        self.name = name
    }

    /// Adds a connection to this room.
    public func join(_ connection: PrismWebSocketConnection) async {
        let connID = connection.id
        connections[connID] = connection
    }

    /// Removes a connection from this room by ID.
    public func leave(_ connectionID: String) {
        connections.removeValue(forKey: connectionID)
    }

    /// Broadcasts a message to all connections in the room.
    public func broadcast(_ message: PrismWebSocketMessage) async {
        for (_, conn) in connections {
            switch message {
            case .text(let text):
                await conn.send(text)
            case .binary(let data):
                await conn.send(data)
            }
        }
    }

    /// Broadcasts a message to all connections except the specified one.
    public func broadcast(_ message: PrismWebSocketMessage, excluding connectionID: String) async {
        for (id, conn) in connections where id != connectionID {
            switch message {
            case .text(let text):
                await conn.send(text)
            case .binary(let data):
                await conn.send(data)
            }
        }
    }

    /// Sends a message to a specific connection by ID.
    public func send(to connectionID: String, message: PrismWebSocketMessage) async {
        guard let conn = connections[connectionID] else { return }
        switch message {
        case .text(let text):
            await conn.send(text)
        case .binary(let data):
            await conn.send(data)
        }
    }

    /// Number of connections in this room.
    public var memberCount: Int { connections.count }

    /// IDs of all connections in this room.
    public var memberIDs: [String] { Array(connections.keys) }

    /// Whether the room has no connections.
    public var isEmpty: Bool { connections.isEmpty }
}

/// Manages named WebSocket rooms.
public actor PrismRoomManager {
    private var roomMap: [String: PrismRoom] = [:]

    /// Creates a new `PrismRoomManager` with the specified configuration.
    public init() {}

    /// Gets or creates a room by name.
    public func room(_ name: String) -> PrismRoom {
        if let existing = roomMap[name] {
            return existing
        }
        let newRoom = PrismRoom(name: name)
        roomMap[name] = newRoom
        return newRoom
    }

    /// Adds a connection to a named room.
    public func join(_ roomName: String, connection: PrismWebSocketConnection) async {
        let r = room(roomName)
        await r.join(connection)
    }

    /// Removes a connection from a named room. Removes room if empty.
    public func leave(_ roomName: String, connectionID: String) async {
        guard let r = roomMap[roomName] else { return }
        await r.leave(connectionID)
        if await r.isEmpty {
            roomMap.removeValue(forKey: roomName)
        }
    }

    /// Removes a connection from all rooms.
    public func leaveAll(connectionID: String) async {
        for (name, r) in roomMap {
            await r.leave(connectionID)
            if await r.isEmpty {
                roomMap.removeValue(forKey: name)
            }
        }
    }

    /// Broadcasts a message to all connections in a room.
    public func broadcast(_ roomName: String, message: PrismWebSocketMessage) async {
        guard let r = roomMap[roomName] else { return }
        await r.broadcast(message)
    }

    /// List of active room names.
    public var rooms: [String] { Array(roomMap.keys) }

    /// Number of active rooms.
    public var roomCount: Int { roomMap.count }
}

/// Tracks user presence metadata per room.
public actor PrismPresence {
    private var presenceMap: [String: [String: [String: String]]] = [:]

    /// Creates a new `PrismPresence` with the specified configuration.
    public init() {}

    /// Tracks a connection in a room with metadata.
    public func track(roomName: String, connectionID: String, meta: [String: String] = [:]) {
        presenceMap[roomName, default: [:]][connectionID] = meta
    }

    /// Removes tracking for a connection in a room.
    public func untrack(roomName: String, connectionID: String) {
        presenceMap[roomName]?.removeValue(forKey: connectionID)
        if presenceMap[roomName]?.isEmpty == true {
            presenceMap.removeValue(forKey: roomName)
        }
    }

    /// Lists all tracked connections and their metadata in a room.
    public func list(roomName: String) -> [(connectionID: String, meta: [String: String])] {
        guard let entries = presenceMap[roomName] else { return [] }
        return entries.map { (connectionID: $0.key, meta: $0.value) }
    }

    /// Number of tracked connections in a room.
    public func count(roomName: String) -> Int {
        presenceMap[roomName]?.count ?? 0
    }
}
