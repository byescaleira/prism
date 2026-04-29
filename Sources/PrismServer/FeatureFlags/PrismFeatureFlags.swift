import Foundation

// MARK: - Feature Flag Types

public enum PrismFlagValue: Sendable {
    case boolean(Bool)
    case percentage(Double)
    case string(String)
    case integer(Int)
}

public struct PrismFlagContext: Sendable {
    public let userId: String?
    public let groups: [String]
    public let attributes: [String: String]

    public init(userId: String? = nil, groups: [String] = [], attributes: [String: String] = [:]) {
        self.userId = userId
        self.groups = groups
        self.attributes = attributes
    }
}

public struct PrismFeatureFlag: Sendable {
    public let name: String
    public let value: PrismFlagValue
    public let description: String?
    public let enabled: Bool
    public let targetUsers: Set<String>
    public let targetGroups: Set<String>
    public let rules: [PrismFlagRule]

    public init(
        name: String,
        value: PrismFlagValue = .boolean(true),
        description: String? = nil,
        enabled: Bool = true,
        targetUsers: Set<String> = [],
        targetGroups: Set<String> = [],
        rules: [PrismFlagRule] = []
    ) {
        self.name = name
        self.value = value
        self.description = description
        self.enabled = enabled
        self.targetUsers = targetUsers
        self.targetGroups = targetGroups
        self.rules = rules
    }
}

// MARK: - Flag Rules

public struct PrismFlagRule: Sendable {
    public enum Operator: String, Sendable {
        case equals, notEquals, contains, startsWith, endsWith
        case greaterThan, lessThan
    }

    public let attribute: String
    public let op: Operator
    public let value: String
    public let result: Bool

    public init(attribute: String, op: Operator, value: String, result: Bool = true) {
        self.attribute = attribute
        self.op = op
        self.value = value
        self.result = result
    }

    public func evaluate(against context: PrismFlagContext) -> Bool? {
        guard let attrValue = context.attributes[attribute] else { return nil }
        let matches: Bool
        switch op {
        case .equals: matches = attrValue == value
        case .notEquals: matches = attrValue != value
        case .contains: matches = attrValue.contains(value)
        case .startsWith: matches = attrValue.hasPrefix(value)
        case .endsWith: matches = attrValue.hasSuffix(value)
        case .greaterThan:
            if let a = Double(attrValue), let b = Double(value) { matches = a > b }
            else { matches = false }
        case .lessThan:
            if let a = Double(attrValue), let b = Double(value) { matches = a < b }
            else { matches = false }
        }
        return matches ? result : !result
    }
}

// MARK: - Feature Flag Store

public actor PrismFeatureFlagStore {
    private var flags: [String: PrismFeatureFlag] = [:]

    public init() {}

    public func register(_ flag: PrismFeatureFlag) {
        flags[flag.name] = flag
    }

    public func registerAll(_ flagList: [PrismFeatureFlag]) {
        for flag in flagList {
            flags[flag.name] = flag
        }
    }

    public func remove(_ name: String) {
        flags.removeValue(forKey: name)
    }

    public func isEnabled(_ name: String, context: PrismFlagContext = PrismFlagContext()) -> Bool {
        guard let flag = flags[name] else { return false }
        guard flag.enabled else { return false }

        if let userId = context.userId, !flag.targetUsers.isEmpty {
            if flag.targetUsers.contains(userId) { return true }
        }

        if !flag.targetGroups.isEmpty {
            for group in context.groups {
                if flag.targetGroups.contains(group) { return true }
            }
            if flag.targetUsers.isEmpty { return false }
        }

        for rule in flag.rules {
            if let result = rule.evaluate(against: context) {
                return result
            }
        }

        switch flag.value {
        case .boolean(let v): return v
        case .percentage(let pct):
            return evaluatePercentage(pct, userId: context.userId, flagName: name)
        case .string: return true
        case .integer: return true
        }
    }

    public func getValue(_ name: String, context: PrismFlagContext = PrismFlagContext()) -> PrismFlagValue? {
        guard let flag = flags[name], flag.enabled else { return nil }
        guard isEnabled(name, context: context) else { return nil }
        return flag.value
    }

    public func getString(_ name: String, context: PrismFlagContext = PrismFlagContext(), default defaultValue: String = "") -> String {
        guard let value = getValue(name, context: context) else { return defaultValue }
        switch value {
        case .string(let s): return s
        case .boolean(let b): return b ? "true" : "false"
        case .integer(let i): return "\(i)"
        case .percentage(let p): return "\(p)"
        }
    }

    public func getInt(_ name: String, context: PrismFlagContext = PrismFlagContext(), default defaultValue: Int = 0) -> Int {
        guard let value = getValue(name, context: context) else { return defaultValue }
        if case .integer(let i) = value { return i }
        return defaultValue
    }

    public func allFlags() -> [PrismFeatureFlag] {
        Array(flags.values)
    }

    public func loadJSON(data: Data) throws {
        guard let arr = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw PrismFeatureFlagError.invalidFormat
        }
        for dict in arr {
            guard let name = dict["name"] as? String else { continue }
            let enabled = dict["enabled"] as? Bool ?? true
            let description = dict["description"] as? String

            var value: PrismFlagValue = .boolean(true)
            if let boolVal = dict["value"] as? Bool {
                value = .boolean(boolVal)
            } else if let intVal = dict["value"] as? Int {
                value = .integer(intVal)
            } else if let dblVal = dict["value"] as? Double {
                value = .percentage(dblVal)
            } else if let strVal = dict["value"] as? String {
                value = .string(strVal)
            }

            let targetUsers = Set((dict["targetUsers"] as? [String]) ?? [])
            let targetGroups = Set((dict["targetGroups"] as? [String]) ?? [])

            let flag = PrismFeatureFlag(
                name: name, value: value, description: description,
                enabled: enabled, targetUsers: targetUsers, targetGroups: targetGroups
            )
            flags[name] = flag
        }
    }

    // MARK: - Private

    private func evaluatePercentage(_ percentage: Double, userId: String?, flagName: String) -> Bool {
        let seed: String
        if let userId {
            seed = "\(flagName):\(userId)"
        } else {
            seed = "\(flagName):\(UUID().uuidString)"
        }
        let hash = stableHash(seed)
        let bucket = Double(hash % 100)
        return bucket < percentage
    }

    private func stableHash(_ string: String) -> UInt64 {
        var hash: UInt64 = 5381
        for byte in string.utf8 {
            hash = ((hash &<< 5) &+ hash) &+ UInt64(byte)
        }
        return hash
    }
}

// MARK: - Feature Flag Middleware

public struct PrismFeatureFlagMiddleware: PrismMiddleware, Sendable {
    private let store: PrismFeatureFlagStore
    private let contextBuilder: @Sendable (PrismHTTPRequest) -> PrismFlagContext

    public init(
        store: PrismFeatureFlagStore,
        contextBuilder: @escaping @Sendable (PrismHTTPRequest) -> PrismFlagContext = { _ in PrismFlagContext() }
    ) {
        self.store = store
        self.contextBuilder = contextBuilder
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        var req = request
        let context = contextBuilder(request)
        let allFlags = await store.allFlags()
        var enabledFlags: [String] = []
        for flag in allFlags {
            if await store.isEnabled(flag.name, context: context) {
                enabledFlags.append(flag.name)
            }
        }
        req.userInfo["featureFlags"] = enabledFlags.joined(separator: ",")
        return try await next(req)
    }
}

// MARK: - Errors

public enum PrismFeatureFlagError: Error, Sendable {
    case invalidFormat
    case flagNotFound(String)
}
