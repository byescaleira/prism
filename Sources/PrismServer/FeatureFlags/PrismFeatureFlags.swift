import Foundation

// MARK: - Feature Flag Types

/// The value type of a feature flag.
public enum PrismFlagValue: Sendable {
    /// A simple on/off boolean flag.
    case boolean(Bool)
    /// A percentage rollout (0-100).
    case percentage(Double)
    /// A string variant value.
    case string(String)
    /// An integer variant value.
    case integer(Int)
}

/// Context passed to feature flag evaluation for targeting.
public struct PrismFlagContext: Sendable {
    /// The user ID for user-level targeting.
    public let userId: String?
    /// The groups the user belongs to.
    public let groups: [String]
    /// Arbitrary key-value attributes for rule evaluation.
    public let attributes: [String: String]

    /// Creates a flag context with optional user ID, groups, and attributes.
    public init(userId: String? = nil, groups: [String] = [], attributes: [String: String] = [:]) {
        self.userId = userId
        self.groups = groups
        self.attributes = attributes
    }
}

/// A feature flag with targeting rules and value.
public struct PrismFeatureFlag: Sendable {
    /// The unique name of this flag.
    public let name: String
    /// The value of this flag.
    public let value: PrismFlagValue
    /// A human-readable description of what this flag controls.
    public let description: String?
    /// Whether this flag is globally enabled.
    public let enabled: Bool
    /// Specific user IDs that should always see this flag enabled.
    public let targetUsers: Set<String>
    /// Groups that should always see this flag enabled.
    public let targetGroups: Set<String>
    /// Attribute-based rules for fine-grained targeting.
    public let rules: [PrismFlagRule]

    /// Creates a feature flag with the given name, value, and targeting options.
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

/// A rule that evaluates a context attribute to determine flag eligibility.
public struct PrismFlagRule: Sendable {
    /// Comparison operators for flag rule evaluation.
    public enum Operator: String, Sendable {
        /// The attribute equals the value.
        case equals
        /// The attribute does not equal the value.
        case notEquals
        /// The attribute contains the value as a substring.
        case contains
        /// The attribute starts with the value.
        case startsWith
        /// The attribute ends with the value.
        case endsWith
        /// The attribute is numerically greater than the value.
        case greaterThan
        /// The attribute is numerically less than the value.
        case lessThan
    }

    /// The context attribute key to evaluate.
    public let attribute: String
    /// The comparison operator.
    public let op: Operator
    /// The value to compare against.
    public let value: String
    /// The result to return if the rule matches.
    public let result: Bool

    /// Creates a flag rule with the given attribute, operator, value, and result.
    public init(attribute: String, op: Operator, value: String, result: Bool = true) {
        self.attribute = attribute
        self.op = op
        self.value = value
        self.result = result
    }

    /// Evaluates this rule against the given context, returning nil if the attribute is missing.
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

/// Actor-based store for managing feature flags and evaluating them against contexts.
public actor PrismFeatureFlagStore {
    private var flags: [String: PrismFeatureFlag] = [:]

    /// Creates an empty feature flag store.
    public init() {}

    /// Registers a feature flag in the store.
    public func register(_ flag: PrismFeatureFlag) {
        flags[flag.name] = flag
    }

    /// Registers multiple feature flags at once.
    public func registerAll(_ flagList: [PrismFeatureFlag]) {
        for flag in flagList {
            flags[flag.name] = flag
        }
    }

    /// Removes a feature flag by name.
    public func remove(_ name: String) {
        flags.removeValue(forKey: name)
    }

    /// Returns whether the named flag is enabled for the given context.
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

    /// Returns the value of the named flag if enabled, or nil otherwise.
    public func getValue(_ name: String, context: PrismFlagContext = PrismFlagContext()) -> PrismFlagValue? {
        guard let flag = flags[name], flag.enabled else { return nil }
        guard isEnabled(name, context: context) else { return nil }
        return flag.value
    }

    /// Returns the string value of the named flag, or the default if not available.
    public func getString(_ name: String, context: PrismFlagContext = PrismFlagContext(), default defaultValue: String = "") -> String {
        guard let value = getValue(name, context: context) else { return defaultValue }
        switch value {
        case .string(let s): return s
        case .boolean(let b): return b ? "true" : "false"
        case .integer(let i): return "\(i)"
        case .percentage(let p): return "\(p)"
        }
    }

    /// Returns the integer value of the named flag, or the default if not available.
    public func getInt(_ name: String, context: PrismFlagContext = PrismFlagContext(), default defaultValue: Int = 0) -> Int {
        guard let value = getValue(name, context: context) else { return defaultValue }
        if case .integer(let i) = value { return i }
        return defaultValue
    }

    /// Returns all registered feature flags.
    public func allFlags() -> [PrismFeatureFlag] {
        Array(flags.values)
    }

    /// Loads feature flags from a JSON data array.
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

/// Middleware that evaluates feature flags and stores enabled flag names in the request.
public struct PrismFeatureFlagMiddleware: PrismMiddleware, Sendable {
    private let store: PrismFeatureFlagStore
    private let contextBuilder: @Sendable (PrismHTTPRequest) -> PrismFlagContext

    /// Creates a feature flag middleware with the given store and context builder.
    public init(
        store: PrismFeatureFlagStore,
        contextBuilder: @escaping @Sendable (PrismHTTPRequest) -> PrismFlagContext = { _ in PrismFlagContext() }
    ) {
        self.store = store
        self.contextBuilder = contextBuilder
    }

    /// Evaluates flags and attaches enabled flag names to the request's userInfo.
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

/// Errors related to feature flag operations.
public enum PrismFeatureFlagError: Error, Sendable {
    /// The JSON data format is invalid.
    case invalidFormat
    /// No flag was found with the given name.
    case flagNotFound(String)
}
