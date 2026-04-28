import Testing
import Foundation
@testable import PrismServer

@Suite("PrismTemplate Tests")
struct PrismTemplateTests {

    @Test("Simple variable interpolation")
    func interpolation() throws {
        let template = PrismTemplate("Hello, {{ name }}!")
        var ctx = PrismTemplateContext()
        ctx.set("name", to: "Alice")
        #expect(try template.render(ctx) == "Hello, Alice!")
    }

    @Test("HTML escaping in interpolation")
    func htmlEscaping() throws {
        let template = PrismTemplate("{{ content }}")
        var ctx = PrismTemplateContext()
        ctx.set("content", to: "<script>alert('xss')</script>")
        let result = try template.render(ctx)
        #expect(result.contains("&lt;script&gt;"))
        #expect(!result.contains("<script>"))
    }

    @Test("Raw interpolation skips escaping")
    func rawInterpolation() throws {
        let template = PrismTemplate("{! html !}")
        var ctx = PrismTemplateContext()
        ctx.set("html", to: "<b>bold</b>")
        let result = try template.render(ctx)
        #expect(result == "<b>bold</b>")
    }

    @Test("If conditional - truthy")
    func ifTruthy() throws {
        let template = PrismTemplate("{% if loggedIn %}Welcome!{% endif %}")
        var ctx = PrismTemplateContext()
        ctx.set("loggedIn", to: "true")
        #expect(try template.render(ctx) == "Welcome!")
    }

    @Test("If conditional - falsy")
    func ifFalsy() throws {
        let template = PrismTemplate("{% if loggedIn %}Welcome!{% endif %}")
        let ctx = PrismTemplateContext()
        #expect(try template.render(ctx) == "")
    }

    @Test("If conditional - false string")
    func ifFalseString() throws {
        let template = PrismTemplate("{% if active %}Yes{% endif %}")
        var ctx = PrismTemplateContext()
        ctx.set("active", to: "false")
        #expect(try template.render(ctx) == "")
    }

    @Test("For loop")
    func forLoop() throws {
        let template = PrismTemplate("{% for item in items %}{{ item }} {% endfor %}")
        var ctx = PrismTemplateContext()
        ctx.set("items", to: ["A", "B", "C"])
        #expect(try template.render(ctx) == "A B C ")
    }

    @Test("Empty for loop")
    func emptyForLoop() throws {
        let template = PrismTemplate("{% for item in items %}{{ item }}{% endfor %}")
        var ctx = PrismTemplateContext()
        ctx.set("items", to: [String]())
        #expect(try template.render(ctx) == "")
    }

    @Test("Include partial")
    func includePartial() throws {
        let template = PrismTemplate("Header: {% include \"nav\" %} Body")
        var ctx = PrismTemplateContext()
        ctx.setPartial("nav", content: "<nav>Menu</nav>")
        #expect(try template.render(ctx) == "Header: <nav>Menu</nav> Body")
    }

    @Test("Missing variable renders empty")
    func missingVariable() throws {
        let template = PrismTemplate("Hello {{ missing }}")
        let ctx = PrismTemplateContext()
        #expect(try template.render(ctx) == "Hello ")
    }

    @Test("Multiple variables")
    func multipleVars() throws {
        let template = PrismTemplate("{{ first }} {{ last }}")
        var ctx = PrismTemplateContext()
        ctx.set("first", to: "John")
        ctx.set("last", to: "Doe")
        #expect(try template.render(ctx) == "John Doe")
    }

    @Test("Template response factory")
    func templateResponse() {
        var ctx = PrismTemplateContext()
        ctx.set("title", to: "Test")
        let response = PrismHTTPResponse.template("<h1>{{ title }}</h1>", context: ctx)
        #expect(response.status == .ok)
        #expect(response.headers.value(for: "Content-Type") == "text/html; charset=utf-8")
    }
}

@Suite("PrismTemplateContext Tests")
struct PrismTemplateContextTests {

    @Test("IsTruthy for various values")
    func isTruthy() {
        var ctx = PrismTemplateContext()
        ctx.set("yes", to: "true")
        ctx.set("no", to: "false")
        ctx.set("zero", to: "0")
        ctx.set("empty", to: "")
        ctx.set("value", to: "something")
        ctx.set("list", to: ["a"])
        ctx.set("emptyList", to: [String]())

        #expect(ctx.isTruthy("yes"))
        #expect(!ctx.isTruthy("no"))
        #expect(!ctx.isTruthy("zero"))
        #expect(!ctx.isTruthy("empty"))
        #expect(ctx.isTruthy("value"))
        #expect(ctx.isTruthy("list"))
        #expect(!ctx.isTruthy("emptyList"))
        #expect(!ctx.isTruthy("missing"))
    }
}
