import Foundation
import Testing

@testable import PrismServer

// MARK: - PrismFlagValue

@Suite("PrismFlagValue")
struct PrismFlagValueTests2 {

    @Test("Boolean case stores value")
    func booleanCase() {
        let val = PrismFlagValue.boolean(true)
        if case .boolean(let b) = val {
            #expect(b == true)
        } else {
            Issue.record("Expected .boolean")
        }
    }

    @Test("Percentage case stores value")
    func percentageCase() {
        let val = PrismFlagValue.percentage(75.5)
        if case .percentage(let p) = val {
            #expect(p == 75.5)
        } else {
            Issue.record("Expected .percentage")
        }
    }

    @Test("String case stores value")
    func stringCase() {
        let val = PrismFlagValue.string("variant-b")
        if case .string(let s) = val {
            #expect(s == "variant-b")
        } else {
            Issue.record("Expected .string")
        }
    }

    @Test("Integer case stores value")
    func integerCase() {
        let val = PrismFlagValue.integer(99)
        if case .integer(let i) = val {
            #expect(i == 99)
        } else {
            Issue.record("Expected .integer")
        }
    }
}

// MARK: - PrismFlagContext

@Suite("PrismFlagContext")
struct PrismFlagContextTests2 {

    @Test("Default context has nil userId, empty groups, empty attributes")
    func defaults() {
        let ctx = PrismFlagContext()
        #expect(ctx.userId == nil)
        #expect(ctx.groups.isEmpty)
        #expect(ctx.attributes.isEmpty)
    }

    @Test("Custom context preserves all values")
    func customValues() {
        let ctx = PrismFlagContext(
            userId: "u-42",
            groups: ["beta", "staff"],
            attributes: ["plan": "enterprise", "region": "us-east"]
        )
        #expect(ctx.userId == "u-42")
        #expect(ctx.groups == ["beta", "staff"])
        #expect(ctx.attributes.count == 2)
        #expect(ctx.attributes["plan"] == "enterprise")
        #expect(ctx.attributes["region"] == "us-east")
    }
}

// MARK: - PrismFlagRule

@Suite("PrismFlagRule")
struct PrismFlagRuleTests2 {

    // --- Operator: equals ---

    @Test("Equals operator matches identical value")
    func equalsMatch() {
        let rule = PrismFlagRule(attribute: "env", op: .equals, value: "production")
        let ctx = PrismFlagContext(attributes: ["env": "production"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("Equals operator rejects different value")
    func equalsNoMatch() {
        let rule = PrismFlagRule(attribute: "env", op: .equals, value: "production")
        let ctx = PrismFlagContext(attributes: ["env": "staging"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    // --- Operator: notEquals ---

    @Test("NotEquals operator matches when different")
    func notEqualsMatch() {
        let rule = PrismFlagRule(attribute: "tier", op: .notEquals, value: "free")
        let ctx = PrismFlagContext(attributes: ["tier": "paid"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("NotEquals operator rejects when identical")
    func notEqualsNoMatch() {
        let rule = PrismFlagRule(attribute: "tier", op: .notEquals, value: "free")
        let ctx = PrismFlagContext(attributes: ["tier": "free"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    // --- Operator: contains ---

    @Test("Contains operator matches substring")
    func containsMatch() {
        let rule = PrismFlagRule(attribute: "email", op: .contains, value: "@acme.com")
        let ctx = PrismFlagContext(attributes: ["email": "dev@acme.com"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("Contains operator rejects missing substring")
    func containsNoMatch() {
        let rule = PrismFlagRule(attribute: "email", op: .contains, value: "@acme.com")
        let ctx = PrismFlagContext(attributes: ["email": "dev@other.com"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    // --- Operator: startsWith ---

    @Test("StartsWith operator matches prefix")
    func startsWithMatch() {
        let rule = PrismFlagRule(attribute: "path", op: .startsWith, value: "/api/v2")
        let ctx = PrismFlagContext(attributes: ["path": "/api/v2/users"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("StartsWith operator rejects non-prefix")
    func startsWithNoMatch() {
        let rule = PrismFlagRule(attribute: "path", op: .startsWith, value: "/api/v2")
        let ctx = PrismFlagContext(attributes: ["path": "/api/v1/users"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    // --- Operator: endsWith ---

    @Test("EndsWith operator matches suffix")
    func endsWithMatch() {
        let rule = PrismFlagRule(attribute: "file", op: .endsWith, value: ".swift")
        let ctx = PrismFlagContext(attributes: ["file": "Main.swift"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("EndsWith operator rejects non-suffix")
    func endsWithNoMatch() {
        let rule = PrismFlagRule(attribute: "file", op: .endsWith, value: ".swift")
        let ctx = PrismFlagContext(attributes: ["file": "Main.kt"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    // --- Operator: greaterThan ---

    @Test("GreaterThan operator matches larger number")
    func greaterThanMatch() {
        let rule = PrismFlagRule(attribute: "score", op: .greaterThan, value: "50")
        let ctx = PrismFlagContext(attributes: ["score": "80"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("GreaterThan operator rejects smaller number")
    func greaterThanNoMatch() {
        let rule = PrismFlagRule(attribute: "score", op: .greaterThan, value: "50")
        let ctx = PrismFlagContext(attributes: ["score": "30"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    @Test("GreaterThan with non-numeric attribute returns false")
    func greaterThanNonNumeric() {
        let rule = PrismFlagRule(attribute: "name", op: .greaterThan, value: "10")
        let ctx = PrismFlagContext(attributes: ["name": "abc"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    // --- Operator: lessThan ---

    @Test("LessThan operator matches smaller number")
    func lessThanMatch() {
        let rule = PrismFlagRule(attribute: "age", op: .lessThan, value: "18")
        let ctx = PrismFlagContext(attributes: ["age": "12"])
        #expect(rule.evaluate(against: ctx) == true)
    }

    @Test("LessThan operator rejects larger number")
    func lessThanNoMatch() {
        let rule = PrismFlagRule(attribute: "age", op: .lessThan, value: "18")
        let ctx = PrismFlagContext(attributes: ["age": "25"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    @Test("LessThan with non-numeric attribute returns false")
    func lessThanNonNumeric() {
        let rule = PrismFlagRule(attribute: "name", op: .lessThan, value: "10")
        let ctx = PrismFlagContext(attributes: ["name": "xyz"])
        #expect(rule.evaluate(against: ctx) == false)
    }

    // --- Missing attribute ---

    @Test("Returns nil when attribute is missing from context")
    func missingAttributeReturnsNil() {
        let rule = PrismFlagRule(attribute: "nonexistent", op: .equals, value: "x")
        let ctx = PrismFlagContext(attributes: [:])
        #expect(rule.evaluate(against: ctx) == nil)
    }

    @Test("Returns nil for missing attribute with any operator")
    func missingAttributeAnyOperator() {
        let operators: [PrismFlagRule.Operator] = [
            .equals, .notEquals, .contains, .startsWith, .endsWith, .greaterThan, .lessThan,
        ]
        let ctx = PrismFlagContext(attributes: [:])
        for op in operators {
            let rule = PrismFlagRule(attribute: "absent", op: op, value: "v")
            #expect(rule.evaluate(against: ctx) == nil)
        }
    }
}

// MARK: - PrismFeatureFlagStore

@Suite("PrismFeatureFlagStore")
struct PrismFeatureFlagStoreTests2 {

    @Test("Register flag and isEnabled returns true for boolean(true)")
    func registerAndIsEnabled() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "new-dashboard", value: .boolean(true))
        await store.register(flag)
        #expect(await store.isEnabled("new-dashboard") == true)
    }

    @Test("isEnabled returns false for disabled flag")
    func disabledFlagReturnsFalse() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "maintenance", value: .boolean(true), enabled: false)
        await store.register(flag)
        #expect(await store.isEnabled("maintenance") == false)
    }

    @Test("isEnabled returns false for unregistered flag")
    func unregisteredFlagReturnsFalse() async {
        let store = PrismFeatureFlagStore()
        #expect(await store.isEnabled("does-not-exist") == false)
    }

    @Test("Target user is enabled when userId matches")
    func targetUserMatches() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "vip-feature", targetUsers: ["user-007"])
        await store.register(flag)
        let ctx = PrismFlagContext(userId: "user-007")
        #expect(await store.isEnabled("vip-feature", context: ctx) == true)
    }

    @Test("Target user is disabled when userId does not match")
    func targetUserNoMatch() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "vip-feature", value: .boolean(false), targetUsers: ["user-007"])
        await store.register(flag)
        let ctx = PrismFlagContext(userId: "user-999")
        #expect(await store.isEnabled("vip-feature", context: ctx) == false)
    }

    @Test("Target group is enabled when group matches")
    func targetGroupMatches() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "admin-tools", targetGroups: ["admins"])
        await store.register(flag)
        let ctx = PrismFlagContext(groups: ["admins"])
        #expect(await store.isEnabled("admin-tools", context: ctx) == true)
    }

    @Test("Target group is disabled when group does not match")
    func targetGroupNoMatch() async {
        let store = PrismFeatureFlagStore()
        let flag = PrismFeatureFlag(name: "admin-tools", targetGroups: ["admins"])
        await store.register(flag)
        let ctx = PrismFlagContext(groups: ["viewers"])
        #expect(await store.isEnabled("admin-tools", context: ctx) == false)
    }

    @Test("Rules evaluate against context attributes")
    func rulesEvaluateAttributes() async {
        let store = PrismFeatureFlagStore()
        let rule = PrismFlagRule(attribute: "plan", op: .equals, value: "enterprise")
        let flag = PrismFeatureFlag(name: "sso", value: .boolean(false), rules: [rule])
        await store.register(flag)

        let matchCtx = PrismFlagContext(attributes: ["plan": "enterprise"])
        #expect(await store.isEnabled("sso", context: matchCtx) == true)

        let noMatchCtx = PrismFlagContext(attributes: ["plan": "free"])
        #expect(await store.isEnabled("sso", context: noMatchCtx) == false)
    }

    @Test("Percentage flag is deterministic for same userId")
    func percentageDeterministic() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "gradual-rollout", value: .percentage(50)))
        let ctx = PrismFlagContext(userId: "deterministic-user")
        let first = await store.isEnabled("gradual-rollout", context: ctx)
        let second = await store.isEnabled("gradual-rollout", context: ctx)
        let third = await store.isEnabled("gradual-rollout", context: ctx)
        #expect(first == second)
        #expect(second == third)
    }

    @Test("getValue returns value when flag is enabled")
    func getValueEnabled() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "theme", value: .string("dark")))
        let val = await store.getValue("theme")
        if case .string(let s) = val {
            #expect(s == "dark")
        } else {
            Issue.record("Expected .string value")
        }
    }

    @Test("getValue returns nil when flag is disabled")
    func getValueDisabled() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "off", value: .string("x"), enabled: false))
        #expect(await store.getValue("off") == nil)
    }

    @Test("getValue returns nil for unregistered flag")
    func getValueUnregistered() async {
        let store = PrismFeatureFlagStore()
        #expect(await store.getValue("ghost") == nil)
    }

    @Test("getString converts boolean value to string")
    func getStringFromBoolean() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "b", value: .boolean(true)))
        #expect(await store.getString("b") == "true")
    }

    @Test("getString converts integer value to string")
    func getStringFromInteger() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "n", value: .integer(256)))
        #expect(await store.getString("n") == "256")
    }

    @Test("getString converts percentage value to string")
    func getStringFromPercentage() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "p", value: .percentage(99.5)))
        #expect(await store.getString("p") == "99.5")
    }

    @Test("getString returns string value directly")
    func getStringDirect() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "s", value: .string("hello")))
        #expect(await store.getString("s") == "hello")
    }

    @Test("getString returns default for missing flag")
    func getStringDefaultForMissing() async {
        let store = PrismFeatureFlagStore()
        #expect(await store.getString("nope", default: "fallback") == "fallback")
    }

    @Test("getInt returns integer value")
    func getIntValue() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "max-retries", value: .integer(3)))
        #expect(await store.getInt("max-retries") == 3)
    }

    @Test("getInt returns default for non-integer flag")
    func getIntDefaultForNonInteger() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "label", value: .string("text")))
        #expect(await store.getInt("label", default: 7) == 7)
    }

    @Test("getInt returns default for missing flag")
    func getIntDefaultForMissing() async {
        let store = PrismFeatureFlagStore()
        #expect(await store.getInt("absent", default: 0) == 0)
    }

    @Test("allFlags returns all registered flags")
    func allFlagsReturnsAll() async {
        let store = PrismFeatureFlagStore()
        await store.registerAll([
            PrismFeatureFlag(name: "alpha"),
            PrismFeatureFlag(name: "bravo"),
            PrismFeatureFlag(name: "charlie"),
        ])
        let all = await store.allFlags()
        #expect(all.count == 3)
        let names = Set(all.map(\.name))
        #expect(names.contains("alpha"))
        #expect(names.contains("bravo"))
        #expect(names.contains("charlie"))
    }

    @Test("remove deletes a registered flag")
    func removeDeletesFlag() async {
        let store = PrismFeatureFlagStore()
        await store.register(PrismFeatureFlag(name: "ephemeral"))
        #expect(await store.isEnabled("ephemeral") == true)
        await store.remove("ephemeral")
        #expect(await store.isEnabled("ephemeral") == false)
        #expect(await store.allFlags().isEmpty)
    }

    @Test("loadJSON parses array of flag dictionaries")
    func loadJSONParsesFlags() async throws {
        let store = PrismFeatureFlagStore()
        let json = """
            [
                {"name": "feat-bool", "value": true, "enabled": true},
                {"name": "feat-str", "value": "dark-mode", "enabled": true},
                {"name": "feat-int", "value": 10},
                {"name": "feat-pct", "value": 0.85},
                {"name": "feat-off", "value": true, "enabled": false}
            ]
            """.data(using: .utf8)!
        try await store.loadJSON(data: json)

        let all = await store.allFlags()
        #expect(all.count == 5)
        #expect(await store.isEnabled("feat-bool") == true)
        #expect(await store.getString("feat-str") == "dark-mode")
        #expect(await store.getInt("feat-int") == 10)
        #expect(await store.isEnabled("feat-off") == false)
    }

    @Test("loadJSON parses targetUsers and targetGroups")
    func loadJSONWithTargets() async throws {
        let store = PrismFeatureFlagStore()
        let json = """
            [{"name": "pilot", "targetUsers": ["alice", "bob"], "targetGroups": ["eng"]}]
            """.data(using: .utf8)!
        try await store.loadJSON(data: json)

        let aliceCtx = PrismFlagContext(userId: "alice")
        #expect(await store.isEnabled("pilot", context: aliceCtx) == true)

        let engCtx = PrismFlagContext(groups: ["eng"])
        #expect(await store.isEnabled("pilot", context: engCtx) == true)

        // When both targetUsers and targetGroups are set, non-matching users
        // fall through to value evaluation (.boolean(true) by default)
        let outsiderCtx = PrismFlagContext(userId: "eve", groups: ["sales"])
        #expect(await store.isEnabled("pilot", context: outsiderCtx) == true)

        // With only targetGroups set (no targetUsers), non-matching groups are denied
        let json2 = """
            [{"name": "gated", "targetGroups": ["eng"]}]
            """.data(using: .utf8)!
        try await store.loadJSON(data: json2)
        let outsider2 = PrismFlagContext(userId: "eve", groups: ["sales"])
        #expect(await store.isEnabled("gated", context: outsider2) == false)
    }

    @Test("loadJSON throws on invalid JSON format")
    func loadJSONInvalidFormat() async {
        let store = PrismFeatureFlagStore()
        let badData = "{\"not\": \"an array\"}".data(using: .utf8)!
        do {
            try await store.loadJSON(data: badData)
            Issue.record("Expected invalidFormat error")
        } catch let error as PrismFeatureFlagError {
            if case .invalidFormat = error {
                // Expected
            } else {
                Issue.record("Expected .invalidFormat, got \(error)")
            }
        } catch {
            Issue.record("Expected PrismFeatureFlagError, got \(error)")
        }
    }
}

// MARK: - PrismFeatureFlagError

@Suite("PrismFeatureFlagError")
struct PrismFeatureFlagErrorTests {

    @Test("invalidFormat error exists")
    func invalidFormatCase() {
        let error = PrismFeatureFlagError.invalidFormat
        let asError: any Error = error
        #expect(asError is PrismFeatureFlagError)
    }

    @Test("flagNotFound error carries name")
    func flagNotFoundCase() {
        let error: PrismFeatureFlagError = .flagNotFound("missing-flag")
        if case .flagNotFound(let name) = error {
            #expect(name == "missing-flag")
        } else {
            Issue.record("Expected .flagNotFound")
        }
    }
}
