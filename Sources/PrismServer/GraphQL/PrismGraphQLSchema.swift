import Foundation

/// GraphQL type system.
public indirect enum PrismGraphQLType: Sendable {
    case string
    case int
    case float
    case boolean
    case id
    case nonNull(PrismGraphQLType)
    case list(PrismGraphQLType)
    case object(String)
    case `enum`(String, [String])
    case input(String)

    /// The type name.
    public var typeName: String {
        switch self {
        case .string: "String"
        case .int: "Int"
        case .float: "Float"
        case .boolean: "Boolean"
        case .id: "ID"
        case .nonNull(let inner): "\(inner.typeName)!"
        case .list(let inner): "[\(inner.typeName)]"
        case .object(let name): name
        case .enum(let name, _): name
        case .input(let name): name
        }
    }

    /// The is non null.
    public var isNonNull: Bool {
        if case .nonNull = self { return true }
        return false
    }
}

/// Information passed to field resolvers.
public struct PrismGraphQLResolveInfo: @unchecked Sendable {
    /// The field name.
    public let fieldName: String
    /// The arguments.
    public let arguments: [String: Any]
    /// The context.
    public let context: (any Sendable)?
    /// The parent value.
    public let parentValue: (any Sendable)?

    /// Creates a new `PrismGraphQLResolveInfo` with the specified configuration.
    public init(fieldName: String, arguments: [String: Any], context: (any Sendable)?, parentValue: (any Sendable)?) {
        self.fieldName = fieldName
        self.arguments = arguments
        self.context = context
        self.parentValue = parentValue
    }

    /// Returns the argument value for the given name, cast to the expected type.
    public func arg<T>(_ name: String) -> T? {
        arguments[name] as? T
    }

    /// Returns the argument value for the given name or throws if missing.
    public func requireArg<T>(_ name: String) throws -> T {
        guard let value = arguments[name] as? T else {
            throw PrismGraphQLExecutionError.missingArgument(name)
        }
        return value
    }
}

/// A single field in a GraphQL object type.
public struct PrismGraphQLField: @unchecked Sendable {
    /// The name.
    public let name: String
    /// The type.
    public let type: PrismGraphQLType
    /// The args.
    public let args: [PrismGraphQLArgument]
    /// The description.
    public let description: String?
    /// The deprecation reason.
    public let deprecationReason: String?
    /// The resolve.
    public let resolve: @Sendable (PrismGraphQLResolveInfo) async throws -> (any Sendable)?

    /// Creates a new `PrismGraphQLField` with the specified configuration.
    public init(
        name: String,
        type: PrismGraphQLType,
        args: [PrismGraphQLArgument] = [],
        description: String? = nil,
        deprecationReason: String? = nil,
        resolve: @escaping @Sendable (PrismGraphQLResolveInfo) async throws -> (any Sendable)?
    ) {
        self.name = name
        self.type = type
        self.args = args
        self.description = description
        self.deprecationReason = deprecationReason
        self.resolve = resolve
    }
}

/// An argument to a GraphQL field.
public struct PrismGraphQLArgument: Sendable {
    /// The name.
    public let name: String
    /// The type.
    public let type: PrismGraphQLType
    /// The default value.
    public let defaultValue: String?
    /// The description.
    public let description: String?

    /// Creates a new `PrismGraphQLArgument` with the specified configuration.
    public init(name: String, type: PrismGraphQLType, defaultValue: String? = nil, description: String? = nil) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.description = description
    }
}

/// A GraphQL object type with named fields.
public struct PrismGraphQLObjectType: Sendable {
    /// The name.
    public let name: String
    /// The fields.
    public let fields: [String: PrismGraphQLField]
    /// The description.
    public let description: String?
    /// The interfaces.
    public let interfaces: [String]

    /// Creates a new `PrismGraphQLObjectType` with the specified configuration.
    public init(name: String, fields: [PrismGraphQLField], description: String? = nil, interfaces: [String] = []) {
        self.name = name
        self.fields = Dictionary(uniqueKeysWithValues: fields.map { ($0.name, $0) })
        self.description = description
        self.interfaces = interfaces
    }
}

/// A complete GraphQL schema with query, mutation, and subscription root types.
public struct PrismGraphQLSchema: Sendable {
    /// The query.
    public let query: PrismGraphQLObjectType
    /// The mutation.
    public let mutation: PrismGraphQLObjectType?
    /// The subscription.
    public let subscription: PrismGraphQLObjectType?
    /// The types.
    public let types: [String: PrismGraphQLObjectType]

    /// Creates a new `PrismGraphQLSchema` with the specified configuration.
    public init(
        query: PrismGraphQLObjectType,
        mutation: PrismGraphQLObjectType? = nil,
        subscription: PrismGraphQLObjectType? = nil,
        types: [PrismGraphQLObjectType] = []
    ) {
        self.query = query
        self.mutation = mutation
        self.subscription = subscription
        var typeMap: [String: PrismGraphQLObjectType] = [:]
        typeMap[query.name] = query
        if let m = mutation { typeMap[m.name] = m }
        if let s = subscription { typeMap[s.name] = s }
        for t in types { typeMap[t.name] = t }
        self.types = typeMap
    }
}

/// Errors during GraphQL execution.
public enum PrismGraphQLExecutionError: Error, Sendable {
    case missingArgument(String)
    case fieldNotFound(String)
    case typeNotFound(String)
    case invalidOperation(String)
    case parserError(String)
}

/// Builder for constructing a GraphQL schema fluently.
public struct PrismGraphQLSchemaBuilder: Sendable {
    private var queryFields: [PrismGraphQLField] = []
    private var mutationFields: [PrismGraphQLField] = []
    private var subscriptionFields: [PrismGraphQLField] = []
    private var objectTypes: [PrismGraphQLObjectType] = []

    /// Creates a new `PrismGraphQLSchemaBuilder` with the specified configuration.
    public init() {}

    /// Registers a query field with the given name and resolver.
    public mutating func query(
        _ name: String,
        type: PrismGraphQLType,
        args: [PrismGraphQLArgument] = [],
        description: String? = nil,
        resolve: @escaping @Sendable (PrismGraphQLResolveInfo) async throws -> (any Sendable)?
    ) {
        queryFields.append(PrismGraphQLField(name: name, type: type, args: args, description: description, resolve: resolve))
    }

    /// Registers a mutation field with the given name and resolver.
    public mutating func mutation(
        _ name: String,
        type: PrismGraphQLType,
        args: [PrismGraphQLArgument] = [],
        description: String? = nil,
        resolve: @escaping @Sendable (PrismGraphQLResolveInfo) async throws -> (any Sendable)?
    ) {
        mutationFields.append(PrismGraphQLField(name: name, type: type, args: args, description: description, resolve: resolve))
    }

    /// Adds a custom object type to the schema.
    public mutating func addType(_ type: PrismGraphQLObjectType) {
        objectTypes.append(type)
    }

    /// Builds the GraphQL schema from registered queries, mutations, and types.
    public func build() -> PrismGraphQLSchema {
        let queryType = PrismGraphQLObjectType(name: "Query", fields: queryFields)
        let mutationType = mutationFields.isEmpty ? nil : PrismGraphQLObjectType(name: "Mutation", fields: mutationFields)
        let subscriptionType = subscriptionFields.isEmpty ? nil : PrismGraphQLObjectType(name: "Subscription", fields: subscriptionFields)
        return PrismGraphQLSchema(query: queryType, mutation: mutationType, subscription: subscriptionType, types: objectTypes)
    }
}
