import Foundation
import Testing

@testable import PrismServer

@Suite("PrismRoom Tests")
struct PrismRoomTests {

    @Test("Room starts empty")
    func roomStartsEmpty() async {
        let room = PrismRoom(name: "chat")
        #expect(await room.memberCount == 0)
        #expect(await room.isEmpty == true)
        #expect(await room.memberIDs.isEmpty)
    }

    @Test("Room stores name")
    func roomName() {
        let room = PrismRoom(name: "lobby")
        #expect(room.name == "lobby")
    }
}

@Suite("PrismRoomManager Tests")
struct PrismRoomManagerTests {

    @Test("Creates room on access")
    func createsRoom() async {
        let manager = PrismRoomManager()
        let room = await manager.room("lobby")
        #expect(room.name == "lobby")
        #expect(await manager.roomCount == 1)
    }

    @Test("Returns existing room")
    func returnsSameRoom() async {
        let manager = PrismRoomManager()
        let r1 = await manager.room("chat")
        let r2 = await manager.room("chat")
        #expect(r1.name == r2.name)
        #expect(await manager.roomCount == 1)
    }

    @Test("Room count tracks rooms")
    func roomCount() async {
        let manager = PrismRoomManager()
        #expect(await manager.roomCount == 0)
        _ = await manager.room("a")
        _ = await manager.room("b")
        #expect(await manager.roomCount == 2)
    }

    @Test("Rooms lists room names")
    func roomsList() async {
        let manager = PrismRoomManager()
        _ = await manager.room("alpha")
        _ = await manager.room("beta")
        let names = await manager.rooms
        #expect(names.contains("alpha"))
        #expect(names.contains("beta"))
    }

    @Test("Starts with zero rooms")
    func startsEmpty() async {
        let manager = PrismRoomManager()
        #expect(await manager.roomCount == 0)
        #expect(await manager.rooms.isEmpty)
    }
}

@Suite("PrismPresence Tests")
struct PrismPresenceTests {

    @Test("Track adds presence")
    func track() async {
        let presence = PrismPresence()
        await presence.track(roomName: "lobby", connectionID: "c1", meta: ["name": "Alice"])
        let list = await presence.list(roomName: "lobby")
        #expect(list.count == 1)
        #expect(list[0].connectionID == "c1")
        #expect(list[0].meta["name"] == "Alice")
    }

    @Test("Untrack removes presence")
    func untrack() async {
        let presence = PrismPresence()
        await presence.track(roomName: "lobby", connectionID: "c1")
        await presence.untrack(roomName: "lobby", connectionID: "c1")
        let list = await presence.list(roomName: "lobby")
        #expect(list.isEmpty)
    }

    @Test("Count tracks presence")
    func count() async {
        let presence = PrismPresence()
        #expect(await presence.count(roomName: "lobby") == 0)
        await presence.track(roomName: "lobby", connectionID: "c1")
        await presence.track(roomName: "lobby", connectionID: "c2")
        #expect(await presence.count(roomName: "lobby") == 2)
    }

    @Test("Multiple rooms independent")
    func multipleRooms() async {
        let presence = PrismPresence()
        await presence.track(roomName: "room1", connectionID: "c1")
        await presence.track(roomName: "room2", connectionID: "c2")
        #expect(await presence.count(roomName: "room1") == 1)
        #expect(await presence.count(roomName: "room2") == 1)
    }

    @Test("Track with empty meta")
    func trackEmptyMeta() async {
        let presence = PrismPresence()
        await presence.track(roomName: "room", connectionID: "c1")
        let list = await presence.list(roomName: "room")
        #expect(list[0].meta.isEmpty)
    }

    @Test("List empty room returns empty")
    func listEmptyRoom() async {
        let presence = PrismPresence()
        let list = await presence.list(roomName: "nonexistent")
        #expect(list.isEmpty)
    }
}
