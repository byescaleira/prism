import Foundation

/// A parsed GraphQL document containing operations.
public struct PrismGraphQLDocument: Sendable {
    /// The list of operations in this document.
    public let operations: [PrismGraphQLOperation]

    /// Returns the first operation in the document.
    public var firstOperation: PrismGraphQLOperation? { operations.first }

    /// Returns the operation with the given name, if any.
    public func operation(named name: String) -> PrismGraphQLOperation? {
        operations.first { $0.name == name }
    }
}

/// A single GraphQL operation (query, mutation, or subscription).
public struct PrismGraphQLOperation: Sendable {
    /// The type of a GraphQL operation.
    public enum OperationType: String, Sendable {
        /// A read operation.
        case query
        /// A write operation.
        case mutation
        /// A real-time data subscription.
        case subscription
    }

    /// The type of this operation (query, mutation, or subscription).
    public let operationType: OperationType
    /// The optional name of this operation.
    public let name: String?
    /// The top-level fields selected by this operation.
    public let selectionSet: [PrismGraphQLSelection]
    /// The variable definitions declared in this operation.
    public let variableDefinitions: [PrismGraphQLVariableDefinition]
}

/// A variable definition in an operation header.
public struct PrismGraphQLVariableDefinition: Sendable {
    /// The variable name (without the `$` prefix).
    public let name: String
    /// The GraphQL type annotation as a string.
    public let type: String
    /// The default value for this variable, if any.
    public let defaultValue: PrismGraphQLValue?
}

/// A selection within a selection set.
public enum PrismGraphQLSelection: Sendable {
    /// A selected field with optional sub-selections.
    case field(PrismGraphQLFieldSelection)
    /// A reference to a named fragment.
    case fragmentSpread(String)
}

/// A field selection with optional alias, arguments, and nested selections.
public struct PrismGraphQLFieldSelection: Sendable {
    /// The alias for this field in the response, if specified.
    public let alias: String?
    /// The field name as defined in the schema.
    public let name: String
    /// The arguments passed to this field.
    public let arguments: [PrismGraphQLArgumentValue]
    /// Nested field selections within this field.
    public let selectionSet: [PrismGraphQLSelection]

    /// The key used in the response (alias if present, otherwise name).
    public var responseName: String { alias ?? name }
}

/// An argument value in a field invocation.
public struct PrismGraphQLArgumentValue: Sendable {
    /// The argument name.
    public let name: String
    /// The argument value.
    public let value: PrismGraphQLValue
}

/// A GraphQL value literal.
public indirect enum PrismGraphQLValue: Sendable {
    /// A string literal.
    case string(String)
    /// An integer literal.
    case int(Int)
    /// A floating-point literal.
    case float(Double)
    /// A boolean literal.
    case boolean(Bool)
    /// A null literal.
    case null
    /// A reference to a variable by name.
    case variable(String)
    /// A list of values.
    case list([PrismGraphQLValue])
    /// An object with named fields.
    case object([String: PrismGraphQLValue])
    /// An enum value.
    case `enum`(String)

    /// Converts this value to a Foundation type.
    public func toAny() -> Any {
        switch self {
        case .string(let s): return s
        case .int(let i): return i
        case .float(let f): return f
        case .boolean(let b): return b
        case .null: return NSNull()
        case .variable: return NSNull()
        case .list(let arr): return arr.map { $0.toAny() }
        case .object(let dict): return dict.mapValues { $0.toAny() }
        case .enum(let e): return e
        }
    }

    /// Resolves variable references using the provided variables dictionary.
    public func resolveVariables(_ variables: [String: Any]) -> Any {
        switch self {
        case .variable(let name): return variables[name] ?? NSNull()
        case .list(let arr): return arr.map { $0.resolveVariables(variables) }
        case .object(let dict): return dict.mapValues { $0.resolveVariables(variables) }
        default: return toAny()
        }
    }
}
