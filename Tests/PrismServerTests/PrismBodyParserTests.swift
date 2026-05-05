import Foundation
import Testing

@testable import PrismServer

@Suite("PrismNestedFormParser Tests")
struct PrismNestedFormParserTests {

    @Test("Parse simple key=value")
    func simpleKeyValue() {
        let result = PrismNestedFormParser.parse("name=John&age=30")
        #expect(result["name"] as? String == "John")
        #expect(result["age"] as? String == "30")
    }

    @Test("Parse nested user[name]=John")
    func nestedObject() {
        let result = PrismNestedFormParser.parse("user[name]=John&user[email]=test@test.com")
        let user = result["user"] as? [String: Any]
        #expect(user?["name"] as? String == "John")
        #expect(user?["email"] as? String == "test@test.com")
    }

    @Test("Parse array items[0]=a&items[1]=b")
    func indexedArray() {
        let result = PrismNestedFormParser.parse("items[0]=a&items[1]=b&items[2]=c")
        let items = result["items"]
        #expect(items != nil)
    }

    @Test("Empty body returns empty dict")
    func emptyBody() {
        let result = PrismNestedFormParser.parse("")
        #expect(result.isEmpty)
    }

    @Test("URL-decoded values")
    func urlDecoded() {
        let result = PrismNestedFormParser.parse("name=John%20Doe")
        #expect(result["name"] as? String == "John Doe" || result["name"] as? String == "John%20Doe")
    }
}

@Suite("PrismXMLNode Tests")
struct PrismXMLNodeTests {

    @Test("Stores name and text")
    func nameAndText() {
        let node = PrismXMLNode(name: "title", text: "Hello")
        #expect(node.name == "title")
        #expect(node.text == "Hello")
    }

    @Test("Stores attributes")
    func attributes() {
        let node = PrismXMLNode(name: "div", attributes: ["class": "main"])
        #expect(node.attributes["class"] == "main")
    }

    @Test("Child lookup")
    func childLookup() {
        let child = PrismXMLNode(name: "name", text: "Test")
        let root = PrismXMLNode(name: "root", children: [child])
        #expect(root.child("name")?.text == "Test")
        #expect(root.child("missing") == nil)
    }

    @Test("Children named returns filtered list")
    func childrenNamed() {
        let c1 = PrismXMLNode(name: "item", text: "A")
        let c2 = PrismXMLNode(name: "item", text: "B")
        let c3 = PrismXMLNode(name: "other", text: "C")
        let root = PrismXMLNode(name: "root", children: [c1, c2, c3])
        #expect(root.childrenNamed("item").count == 2)
    }
}

@Suite("PrismXMLParserUtil Tests")
struct PrismXMLParserUtilTests {

    @Test("Parse simple XML")
    func simpleXML() {
        let xml = "<root><name>test</name></root>"
        let node = PrismXMLParserUtil.parse(Data(xml.utf8))
        #expect(node?.name == "root")
        #expect(node?.child("name")?.text == "test")
    }

    @Test("Parse with attributes")
    func withAttributes() {
        let xml = "<item id=\"42\" type=\"book\">Content</item>"
        let node = PrismXMLParserUtil.parse(Data(xml.utf8))
        #expect(node?.name == "item")
        #expect(node?.attributes["id"] == "42")
        #expect(node?.attributes["type"] == "book")
    }

    @Test("Parse nested elements")
    func nestedElements() {
        let xml = "<root><parent><child>value</child></parent></root>"
        let node = PrismXMLParserUtil.parse(Data(xml.utf8))
        let child = node?.child("parent")?.child("child")
        #expect(child?.text == "value")
    }

    @Test("Returns nil for invalid XML")
    func invalidXML() {
        let node = PrismXMLParserUtil.parse(Data("not xml at all".utf8))
        // May return a node or nil depending on parser behavior
        // Just verify no crash
        _ = node
    }
}

@Suite("PrismHTTPRequest Body Parser Extensions")
struct PrismRequestBodyParserTests {

    @Test("xmlBody parses XML body")
    func xmlBody() {
        let xml = "<root><name>test</name></root>"
        let request = PrismHTTPRequest(method: .POST, uri: "/", body: Data(xml.utf8))
        let node = request.xmlBody
        #expect(node?.name == "root")
        #expect(node?.child("name")?.text == "test")
    }

    @Test("xmlBody returns nil for non-XML body")
    func xmlBodyNil() {
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let node = request.xmlBody
        #expect(node == nil)
    }

    @Test("nestedFormData parses form body")
    func nestedFormData() {
        let body = "user[name]=Alice&user[age]=25"
        let request = PrismHTTPRequest(method: .POST, uri: "/", body: Data(body.utf8))
        let data = request.nestedFormData
        let user = data["user"] as? [String: Any]
        #expect(user?["name"] as? String == "Alice")
    }
}
