import Testing
import Foundation
@testable import PrismServer

@Suite("PrismFlagValue Tests")
struct PrismFlagValueTests {

    @Test("Boolean flag value")
    func booleanValue() {
        let val = PrismFlagValue.boolean(true)
        if case .boolean(let b) = val {
            #expect(b == true)
        } else {
            Issue.record("Expected boolean")
        }
    }

    @Test("Percentage flag value")
    func percentageValue() {
        let val = PrismFlagValue.percentage(50.0)
        if case .percentage(let p) = val {
            #expect(p == 50.0)
        } else {
            Issue.record("Expected percentage")
        }
    }

    @Test("String flag value")
    func stringValue() {
        let val = PrismFlagValue.string("variant-a")
        if case .string(let s) = val {
            #expect(s == "variant-a")
        } else {
            Issue.record("Expected string")
        }
    }

    @Test("Integer flag value")
    func integerValue() {
        let val = PrismFlagValue.integer(42)
        if case .integer(let i) = val {
            #expect(i == 42)
        } else {
            Issue.record("Expected integer")
        }
    }
}

@Suite("PrismFlagContext Tests")
struct PrismFlagContextTests {

    @Test("Default context")
    func defaults() {
        let ctx = PrismFlagContext()
        #expect(ctx.userId == nil)
        #expect(ctx.groups.isEmpty)
        #expect(ctx.attributes.isEmpty)
    }

    @Test("Custom context")
    func custom() {
        let ctx = PrismFlagContext(userId: "user1", groups: ["beta"], attributes: ["plan": "pro"])
        #expect(ctx.userId == "user1")
        #expect(ctx.groups == ["beta"])
        #expect(ctx.attributes["plan"] == "pro")
    }
}

@Suite("PrismFlagRule Tests")
struct PrismFlagRuleTests {

    @Test("Equals operator matches")
    func equalsMatch() {
        let rule = PrismFlagRule(attribute: "plan", op: .equals, value: "pro")
        let ctx = PrismFlagContext(attributes: ["plan": "pro"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("Equals operator no match")
    func equalsNoMatch() {
        let rule = PrismFlagRule(attribute: "plan", op: .equals, value: "pro")
        let ctx = PrismFlagContext(attributes: ["plan": "free"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    @Test("NotEquals operator")
    func notEquals() {
        let rule = PrismFlagRule(attribute: "plan", op: .notEquals, value: "free")
        let ctx = PrismFlagContext(attributes: ["plan": "pro"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("Contains operator")
    func contains() {
        let rule = PrismFlagRule(attribute: "email", op: .contains, value: "@test.com")
        let ctx = PrismFlagContext(attributes: ["email": "user@test.com"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("StartsWith operator")
    func startsWith() {
        let rule = PrismFlagRule(attribute: "name", op: .startsWith, value: "John")
        let ctx = PrismFlagContext(attributes: ["name": "John Doe"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("EndsWith operator")
    func endsWith() {
        let rule = PrismFlagRule(attribute: "name", op: .endsWith, value: "Doe")
        let ctx = PrismFlagContext(attributes: ["name": "John Doe"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("GreaterThan operator with numbers")
    func greaterThan() {
        let rule = PrismFlagRule(attribute: "age", op: .greaterThan, value: "18")
        let ctx = PrismFlagContext(attributes: ["age": "25"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("LessThan operator with numbers")
    func lessThan() {
        let rule = PrismFlagRule(attribute: "age", op: .lessThan, value: "18")
        let ctx = PrismFlagContext(attributes: ["age": "12"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("GreaterThan with non-numeric returns false")
    func greaterThanNonNumeric() {
        let rule = PrismFlagRule(attribute: "name", op: .greaterThan, value: "18")
        let ctx = PrismFlagContext(attributes: ["name": "abc"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    @Test("Missing attribute returns nil")
    func missingAttribute() {
        let rule = PrismFlagRule(attribute: "missing", op: .equals, value: "x")
        let ctx = PrismFlagContext(attributes: [:])
        #expect(rule.evaluate(against: ctx) == nil)
    }

    @Test("Result inversion when rule does not match")
    func resultInversion() {
        let rule = PrismFlagRule(attribute: "plan", op: .equals, value: "pro", result: false)
        let ctx = PrismFlagContext(attributes: ["plan": "pro"])
        #expect(rule.evaluate(against: ctx) == false)
    }
}

@Suite("PrismFeatureFlagStore Tests")
struct PrismFeatureFlagStoreTests {

    @Test("Register and check enabled flag")
    func registerAndCheck() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "dark-mode", value: .boolean(true))
        await store.register(flag)
        #expect(await store.isEnabled("dark-mode") == true)
    }

    @Test("Unregistered flag returns false")
    func unregisteredFlag() async {
        let store = PrismFeatureFlagStore()
        #expect(await store.isEnabled("nonexistent") == false)
    }

    @Test("Disabled flag returns false")
    func disabledFlag() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "feature", enabled: false)
        await store.register(flag)
        #expect(await store.isEnabled("feature") == false)
    }

    @Test("Boolean false value returns false")
    func booleanFalseValue() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "feature", value: .boolean(false))
        await store.register(flag)
        #expect(await store.isEnabled("feature") == false)
    }

    @Test("Target user gets flag enabled")
    func targetUser() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "beta", targetUsers: ["user1"])
        await store.register(flag)
        let ctx = PrismFlagContext(userId: "user1")
        #expect(await store.isEnabled("beta", context: ctx) == true)
    }

    @Test("Non-target user excluded")
    func nonTargetUser() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "beta", value: .boolean(false), targetUsers: ["user1"])
        await store.register(flag)
        let ctx = PrismFlagContext(userId: "user2")
        #expect(await store.isEnabled("beta", context: ctx) == false)
    }

    @Test("Target group gets flag enabled")
    func targetGroup() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "admin-panel", targetGroups: ["admins"])
        await store.register(flag)
        let ctx = PrismFlagContext(groups: ["admins"])
        #expect(await store.isEnabled("admin-panel", context: ctx) == true)
    }

    @Test("Non-target group excluded when targetGroups set")
    func nonTargetGroup() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "admin-panel", targetGroups: ["admins"])
        await store.register(flag)
        let ctx = PrismFlagContext(groups: ["users"])
        #expect(await store.isEnabled("admin-panel", context: ctx) == false)
    }

    @Test("Rule evaluation overrides default")
    func ruleEvaluation() async {
        let store = PrismFeatureFlagStore()
        let rule = PrismFlagRule(attribute: "plan", op: .equals, value: "enterprise")
        let flag = PrismFeatureFlag(name: "advanced", value: .boolean(false), rules: [rule])
        await store.register(flag)
        let ctx = PrismFlagContext(attributes: ["plan": "enterprise"])
        #expect(await store.isEnabled("advanced", context: ctx) == true)
    }

    @Test("Remove flag")
    func removeFlag() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "temp"))
        await store.remove("temp")
        #expect(await store.isEnabled("temp") == false)
    }

    @Test("RegisterAll registers multiple flags")
    func registerAll() async {
        let store = PrismFeatureFlagStore()
        await store.registerAll([
            PrismFeatureFlag(name: "a"),
            PrismFeatureFlag(name: "b"),
        ])
        #expect(await store.isEnabled("a") == true)
        #expect(await store.isEnabled("b") == true)
    }

    @Test("AllFlags returns registered flags")
    func allFlags() async {
        let store = PrismFeatureFlagStore()
        await store.registerAll([
            PrismFeatureFlag(name: "x"),
            PrismFeatureFlag(name: "y"),
        ])
        let all = await store.allFlags()
        #expect(all.count == 2)
    }

    @Test("GetValue returns value for enabled flag")
    func getValue() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "theme", value: .string("dark")))
        let val = await store.getValue("theme")
        if case .string(let s) = val {
            #expect(s == "dark")
        } else {
            Issue.record("Expected string value")
        }
    }

    @Test("GetValue returns nil for disabled flag")
    func getValueDisabled() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "off", enabled: false))
        #expect(await store.getValue("off") == nil)
    }

    @Test("GetString returns string value")
    func getString() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "color", value: .string("blue")))
        #expect(await store.getString("color") == "blue")
    }

    @Test("GetString returns default for missing flag")
    func getStringDefault() async {
        let store = PrismFeatureFlagStore()
        #expect(await store.getString("missing", default: "fallback") == "fallback")
    }

    @Test("GetInt returns integer value")
    func getInt() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "limit", value: .integer(100)))
        #expect(await store.getInt("limit") == 100)
    }

    @Test("GetInt returns default for non-integer")
    func getIntDefault() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "str", value: .string("abc")))
        #expect(await store.getInt("str", default: 42) == 42)
    }

    @Test("LoadJSON parses flags from JSON data")
    func loadJSON() async throws {
        let store = PrismFeatureFlagStore()
        let json = """
        [
            {"name": "flag1", "value": true, "enabled": true},
            {"name": "flag2", "value": "variant-a", "enabled": false},
            {"name": "flag3", "value": 42},
            {"name": "flag4", "value": 0.75}
        ]
        """.data(using: .utf8)!
        try await store.loadJSON(data: json)

        #expect(await store.isEnabled("flag1") == true)
        #expect(await store.isEnabled("flag2") == false)
        #expect(await store.getInt("flag3") == 42)

        let allFlags = await store.allFlags()
        #expect(allFlags.count == 4)
    }

    @Test("LoadJSON with targetUsers and targetGroups")
    func loadJSONTargets() async throws {
        let store = PrismFeatureFlagStore()
        let json = """
        [{"name": "beta", "targetUsers": ["u1", "u2"], "targetGroups": ["staff"]}]
        """.data(using: .utf8)!
        try await store.loadJSON(data: json)
        let ctx = PrismFlagContext(userId: "u1")
        #expect(await store.isEnabled("beta", context: ctx) == true)
    }

    @Test("LoadJSON throws on invalid format")
    func loadJSONInvalid() async {
        let store = PrismFeatureFlagStore()
        let data = "not json".data(using: .utf8)!
        do {
            try await store.loadJSON(data: data)
            Issue.record("Expected error")
        } catch {
            // Valid — JSONSerialization or PrismFeatureFlagError
        }
    }

    @Test("Percentage flag is deterministic for same user")
    func percentageDeterministic() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "rollout", value: .percentage(50)))
        let ctx = PrismFlagContext(userId: "stable-user")
        let first = await store.isEnabled("rollout", context: ctx)
        let second = await store.isEnabled("rollout", context: ctx)
        #expect(first == second)
    }
}

@Suite("PrismFeatureFlagMiddleware Tests")
struct PrismFeatureFlagMiddlewareTests {

    @Test("Sets featureFlags in userInfo")
    func setsUserInfo() async throws {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "dark-mode"))
        await store.register(PrismFeatureFlag(name: "new-ui"))

        let middleware = PrismFeatureFlagMiddleware(store: store)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        _ = try await middleware.handle(request) { req in
            let flags = req.userInfo["featureFlags"] ?? ""
            #expect(flags.contains("dark-mode"))
            #expect(flags.contains("new-ui"))
            return .text("ok")
        }
    }

    @Test("Disabled flags not in userInfo")
    func disabledExcluded() async throws {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "on"))
        await store.register(PrismFeatureFlag(name: "off", enabled: false))

        let middleware = PrismFeatureFlagMiddleware(store: store)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")

        _ = try await middleware.handle(request) { req in
            let flags = req.userInfo["featureFlags"] ?? ""
            #expect(flags.contains("on"))
            #expect(!flags.contains("off"))
            return .text("ok")
        }
    }
}
