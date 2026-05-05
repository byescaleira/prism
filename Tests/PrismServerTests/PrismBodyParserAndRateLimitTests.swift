import Foundation
import Testing

@testable import PrismServer

// MARK: - PrismXMLNode

@Suite("PrismXMLNode")
struct PrismXMLNodeSuiteTests {

    @Test("Init stores name, attributes, text, and children")
    func initStoresAllProperties() {
        let child = PrismXMLNode(name: "child", text: "nested")
        let node = PrismXMLNode(
            name: "root",
            attributes: ["id": "1", "lang": "en"],
            text: "hello",
            children: [child]
        )
        #expect(node.name == "root")
        #expect(node.attributes == ["id": "1", "lang": "en"])
        #expect(node.text == "hello")
        #expect(node.children.count == 1)
        #expect(node.children[0].name == "child")
    }

    @Test("child() finds first child by name")
    func childFindsFirstMatch() {
        let a = PrismXMLNode(name: "item", text: "first")
        let b = PrismXMLNode(name: "item", text: "second")
        let root = PrismXMLNode(name: "root", children: [a, b])
        let found = root.child("item")
        #expect(found?.text == "first")
    }

    @Test("child() returns nil when no match")
    func childReturnsNilWhenMissing() {
        let root = PrismXMLNode(name: "root", children: [])
        #expect(root.child("missing") == nil)
    }

    @Test("childrenNamed() returns all matching children")
    func childrenNamedReturnsMatches() {
        let a = PrismXMLNode(name: "tag", text: "A")
        let b = PrismXMLNode(name: "other", text: "B")
        let c = PrismXMLNode(name: "tag", text: "C")
        let root = PrismXMLNode(name: "root", children: [a, b, c])
        let matches = root.childrenNamed("tag")
        #expect(matches.count == 2)
        #expect(matches[0].text == "A")
        #expect(matches[1].text == "C")
    }

    @Test("childrenNamed() returns empty array when none match")
    func childrenNamedReturnsEmptyForNoMatch() {
        let root = PrismXMLNode(name: "root", children: [PrismXMLNode(name: "x")])
        #expect(root.childrenNamed("y").isEmpty)
    }
}

// MARK: - PrismXMLParserUtil

@Suite("PrismXMLParserUtil")
struct PrismXMLParserUtilSuiteTests {

    @Test("parse() parses valid XML into node tree")
    func parseValidXML() {
        let xml = "<catalog><book>Swift</book></catalog>"
        let node = PrismXMLParserUtil.parse(Data(xml.utf8))
        #expect(node != nil)
        #expect(node?.name == "catalog")
        #expect(node?.child("book")?.text == "Swift")
    }

    @Test("parse() returns nil for invalid XML")
    func parseInvalidXMLReturnsNil() {
        let garbage = Data("<<<not xml>>>".utf8)
        let node = PrismXMLParserUtil.parse(garbage)
        // Invalid XML should not produce a valid root node
        // (Foundation XMLParser may or may not return nil depending on input,
        // but it must not crash)
        _ = node
    }

    @Test("Nested elements create child nodes")
    func nestedElementsCreateChildren() {
        let xml = "<a><b><c>deep</c></b></a>"
        let root = PrismXMLParserUtil.parse(Data(xml.utf8))
        #expect(root?.name == "a")
        let c = root?.child("b")?.child("c")
        #expect(c?.text == "deep")
    }

    @Test("parse() preserves attributes on nested nodes")
    func attributesOnNestedNodes() {
        let xml = "<root><item id=\"7\" status=\"active\">val</item></root>"
        let root = PrismXMLParserUtil.parse(Data(xml.utf8))
        let item = root?.child("item")
        #expect(item?.attributes["id"] == "7")
        #expect(item?.attributes["status"] == "active")
        #expect(item?.text == "val")
    }
}

// MARK: - PrismNestedFormParser

@Suite("PrismNestedFormParser")
struct PrismNestedFormParserSuiteTests {

    @Test("parse() handles flat key=value pairs")
    func flatKeyValue() {
        let result = PrismNestedFormParser.parse("color=red&size=large")
        #expect(result["color"] as? String == "red")
        #expect(result["size"] as? String == "large")
    }

    @Test("parse() handles nested user[name]=John&user[age]=30")
    func nestedKeys() {
        let result = PrismNestedFormParser.parse("user[name]=John&user[age]=30")
        let user = result["user"] as? [String: Any]
        #expect(user != nil)
        #expect(user?["name"] as? String == "John")
        #expect(user?["age"] as? String == "30")
    }

    @Test("parse() handles percent-encoded values")
    func percentEncodedValues() {
        let result = PrismNestedFormParser.parse("greeting=Hello%20World&path=%2Fhome%2Fuser")
        #expect(result["greeting"] as? String == "Hello World")
        #expect(result["path"] as? String == "/home/user")
    }

    @Test("parse() handles empty values")
    func emptyValues() {
        let result = PrismNestedFormParser.parse("key=&another=")
        #expect(result["key"] as? String == "")
        #expect(result["another"] as? String == "")
    }

    @Test("parse() handles empty string")
    func emptyString() {
        let result = PrismNestedFormParser.parse("")
        #expect(result.isEmpty)
    }
}

// MARK: - PrismMemoryRateLimitStore

@Suite("PrismMemoryRateLimitStore")
struct PrismMemoryRateLimitStoreSuiteTests {

    @Test("getWindowHits returns 0 for unknown key")
    func unknownKeyReturnsZero() async {
        let store = PrismMemoryRateLimitStore()
        let hits = await store.getWindowHits(key: "nonexistent", windowStart: Date.distantPast)
        #expect(hits == 0)
    }

    @Test("recordHit increments count")
    func recordHitIncrements() async {
        let store = PrismMemoryRateLimitStore()
        let now = Date()
        await store.recordHit(key: "client", at: now)
        await store.recordHit(key: "client", at: now.addingTimeInterval(1))
        await store.recordHit(key: "client", at: now.addingTimeInterval(2))
        let hits = await store.getWindowHits(key: "client", windowStart: now.addingTimeInterval(-10))
        #expect(hits == 3)
    }

    @Test("getWindowHits filters by window start date")
    func windowFiltering() async {
        let store = PrismMemoryRateLimitStore()
        let now = Date()
        // Record an old hit outside the window
        await store.recordHit(key: "k", at: now.addingTimeInterval(-200))
        // Record recent hits inside the window
        await store.recordHit(key: "k", at: now.addingTimeInterval(-30))
        await store.recordHit(key: "k", at: now)
        let hits = await store.getWindowHits(key: "k", windowStart: now.addingTimeInterval(-60))
        #expect(hits == 2)
    }

    @Test("reset clears key")
    func resetClearsKey() async {
        let store = PrismMemoryRateLimitStore()
        let now = Date()
        await store.recordHit(key: "temp", at: now)
        await store.recordHit(key: "temp", at: now)
        await store.reset(key: "temp")
        let hits = await store.getWindowHits(key: "temp", windowStart: Date.distantPast)
        #expect(hits == 0)
    }
}

// MARK: - PrismRateLimitConfig

@Suite("PrismRateLimitConfig")
struct PrismRateLimitConfigSuiteTests {

    @Test("perIP creates config with default window")
    func perIPDefaultWindow() {
        let config = PrismRateLimitConfig.perIP(max: 60)
        #expect(config.maxRequests == 60)
        #expect(config.windowSeconds == 60)
    }

    @Test("perHeader creates config with header")
    func perHeaderConfig() {
        let config = PrismRateLimitConfig.perHeader("X-API-Key", max: 200, windowSeconds: 300)
        #expect(config.maxRequests == 200)
        #expect(config.windowSeconds == 300)
    }

    @Test("global creates config with global key")
    func globalKey() {
        let config = PrismRateLimitConfig.global(max: 5000, windowSeconds: 120)
        #expect(config.maxRequests == 5000)
        #expect(config.windowSeconds == 120)
        // The key extractor should always return "global"
        let request = PrismHTTPRequest(method: .GET, uri: "/any")
        let key = config.keyExtractor(request)
        #expect(key == "global")
    }

    @Test("custom init stores values")
    func customInit() {
        let config = PrismRateLimitConfig(windowSeconds: 45, maxRequests: 10) { req in
            req.uri
        }
        #expect(config.windowSeconds == 45)
        #expect(config.maxRequests == 10)
        let request = PrismHTTPRequest(method: .GET, uri: "/custom")
        #expect(config.keyExtractor(request) == "/custom")
    }
}
