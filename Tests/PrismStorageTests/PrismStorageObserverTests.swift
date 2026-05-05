import Foundation
import Testing

@testable import PrismStorage

@Suite("ObsStore")
struct PrismStorageObserverTests {
    func makeObserver() -> PrismStorageObserver {
        let defaults = PrismDefaultsStore(
            suite: "ObsTest-\(UUID().uuidString)"
        )
        return PrismStorageObserver(wrapping: defaults)
    }

    @Test("Save emits saved event")
    func saveEvent() async throws {
        let observer = makeObserver()
        let stream = observer.events()

        try observer.save("val", forKey: "k")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.saved(key: "k")])
    }

    @Test("Delete emits deleted event")
    func deleteEvent() async throws {
        let observer = makeObserver()
        try observer.save("v", forKey: "d")
        let stream = observer.events()

        try observer.delete(forKey: "d")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.deleted(key: "d")])
    }

    @Test("Clear emits cleared event")
    func clearEvent() async throws {
        let observer = makeObserver()
        try observer.save("v", forKey: "c")
        let stream = observer.events()

        try observer.clear()

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.cleared])
    }

    @Test("Load emits loaded event when value exists")
    func loadEvent() async throws {
        let observer = makeObserver()
        try observer.save("v", forKey: "l")
        let stream = observer.events()

        _ = try observer.load(String.self, forKey: "l")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.loaded(key: "l")])
    }

    @Test("Passthrough operations work correctly")
    func passthrough() throws {
        let observer = makeObserver()
        try observer.save("a", forKey: "p1")
        try observer.save("b", forKey: "p2")
        #expect(try observer.exists(forKey: "p1"))
        #expect(try observer.keys().sorted() == ["p1", "p2"])
        let loaded = try observer.load(String.self, forKey: "p1")
        #expect(loaded == "a")
    }
}
