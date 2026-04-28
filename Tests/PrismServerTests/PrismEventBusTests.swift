import Testing
import Foundation
@testable import PrismServer

struct TestEvent: PrismEvent {
    let value: String
}

struct AnotherEvent: PrismEvent {
    let count: Int
}

@Suite("PrismEventBus Tests")
struct PrismEventBusTests {

    @Test("On and emit delivers event")
    func onAndEmit() async {
        let bus = PrismEventBus()
        let received = ReceivedBox()

        await bus.on(TestEvent.self) { event in
            await received.set(event.value)
        }

        await bus.emit(TestEvent(value: "hello"))
        let val = await received.value
        #expect(val == "hello")
    }

    @Test("Multiple listeners receive event")
    func multipleListeners() async {
        let bus = PrismEventBus()
        let counter = Counter()

        await bus.on(TestEvent.self) { _ in await counter.increment() }
        await bus.on(TestEvent.self) { _ in await counter.increment() }

        await bus.emit(TestEvent(value: "x"))
        let count = await counter.value
        #expect(count == 2)
    }

    @Test("Off removes listener")
    func offRemoves() async {
        let bus = PrismEventBus()
        let counter = Counter()

        let id = await bus.on(TestEvent.self) { _ in await counter.increment() }
        await bus.off(id: id)
        await bus.emit(TestEvent(value: "x"))

        let count = await counter.value
        #expect(count == 0)
    }

    @Test("Once fires only once")
    func onceFiresOnce() async {
        let bus = PrismEventBus()
        let counter = Counter()

        await bus.once(TestEvent.self) { _ in await counter.increment() }

        await bus.emit(TestEvent(value: "first"))
        await bus.emit(TestEvent(value: "second"))

        let count = await counter.value
        #expect(count == 1)
    }

    @Test("RemoveAll clears listeners for type")
    func removeAllForType() async {
        let bus = PrismEventBus()
        let counter = Counter()

        await bus.on(TestEvent.self) { _ in await counter.increment() }
        await bus.on(TestEvent.self) { _ in await counter.increment() }
        await bus.removeAll(for: TestEvent.self)

        await bus.emit(TestEvent(value: "x"))
        let count = await counter.value
        #expect(count == 0)
    }

    @Test("ListenerCount returns correct count")
    func listenerCount() async {
        let bus = PrismEventBus()
        #expect(await bus.listenerCount(for: TestEvent.self) == 0)

        await bus.on(TestEvent.self) { _ in }
        #expect(await bus.listenerCount(for: TestEvent.self) == 1)

        await bus.on(TestEvent.self) { _ in }
        #expect(await bus.listenerCount(for: TestEvent.self) == 2)
    }

    @Test("Different event types are independent")
    func differentTypes() async {
        let bus = PrismEventBus()
        let stringBox = ReceivedBox()
        let counter = Counter()

        await bus.on(TestEvent.self) { event in await stringBox.set(event.value) }
        await bus.on(AnotherEvent.self) { _ in await counter.increment() }

        await bus.emit(TestEvent(value: "only-test"))
        let val = await stringBox.value
        let count = await counter.value
        #expect(val == "only-test")
        #expect(count == 0)
    }

    @Test("Event name defaults to type name")
    func eventNameDefault() {
        #expect(TestEvent.name == "TestEvent")
        #expect(AnotherEvent.name == "AnotherEvent")
    }
}

private actor ReceivedBox {
    var value: String?
    func set(_ v: String) { value = v }
}

private actor Counter {
    var value: Int = 0
    func increment() { value += 1 }
}
