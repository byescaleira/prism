import Foundation

/// Result of executing a GraphQL operation.
public struct PrismGraphQLResult: @unchecked Sendable {
    /// The result data, if the operation succeeded.
    public let data: [String: Any]?
    /// The errors encountered during execution, if any.
    public let errors: [PrismGraphQLError]?

    /// Creates a GraphQL result with optional data and errors.
    public init(data: [String: Any]?, errors: [PrismGraphQLError]?) {
        self.data = data
        self.errors = errors.flatMap { $0.isEmpty ? nil : $0 }
    }

    /// Serializes this result to JSON data.
    public func toJSON() -> Data {
        var dict: [String: Any] = [:]
        if let data { dict["data"] = sanitize(data) }
        if let errors {
            dict["errors"] = errors.map { $0.toDict() }
        }
        return (try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])) ?? Data()
    }

    private func sanitize(_ value: Any) -> Any {
        if let dict = value as? [String: Any] {
            return dict.mapValues { sanitize($0) }
        } else if let arr = value as? [Any] {
            return arr.map { sanitize($0) }
        } else if value is NSNull {
            return NSNull()
        } else if let n = value as? Int {
            return n
        } else if let n = value as? Double {
            return n
        } else if let b = value as? Bool {
            return b
        } else if let s = value as? String {
            return s
        } else {
            return "\(value)"
        }
    }
}

/// A single GraphQL error.
public struct PrismGraphQLError: Sendable {
    /// The error message.
    public let message: String
    /// The field path where the error occurred.
    public let path: [String]?
    /// The source locations in the query where the error originated.
    public let locations: [PrismGraphQLSourceLocation]?

    /// Creates a GraphQL error with the given message, path, and locations.
    public init(message: String, path: [String]? = nil, locations: [PrismGraphQLSourceLocation]? = nil) {
        self.message = message
        self.path = path
        self.locations = locations
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = ["message": message]
        if let path { dict["path"] = path }
        if let locations {
            dict["locations"] = locations.map { ["line": $0.line, "column": $0.column] }
        }
        return dict
    }
}

/// Source location in a GraphQL document.
public struct PrismGraphQLSourceLocation: Sendable {
    /// The line number in the source document.
    public let line: Int
    /// The column number in the source document.
    public let column: Int
}

/// Executes parsed GraphQL documents against a schema.
public struct PrismGraphQLExecutor: Sendable {
    /// Creates a GraphQL executor.
    public init() {}

    /// Executes a parsed GraphQL document against the given schema.
    public func execute(
        document: PrismGraphQLDocument,
        schema: PrismGraphQLSchema,
        context: (any Sendable)? = nil,
        variables: [String: Any] = [:],
        operationName: String? = nil
    ) async -> PrismGraphQLResult {
        let operation: PrismGraphQLOperation
        if let name = operationName {
            guard let op = document.operation(named: name) else {
                return PrismGraphQLResult(
                    data: nil,
                    errors: [
                        PrismGraphQLError(message: "Operation '\(name)' not found")
                    ])
            }
            operation = op
        } else {
            guard let op = document.firstOperation else {
                return PrismGraphQLResult(
                    data: nil,
                    errors: [
                        PrismGraphQLError(message: "No operations in document")
                    ])
            }
            operation = op
        }

        let rootType: PrismGraphQLObjectType
        switch operation.operationType {
        case .query:
            rootType = schema.query
        case .mutation:
            guard let m = schema.mutation else {
                return PrismGraphQLResult(
                    data: nil,
                    errors: [
                        PrismGraphQLError(message: "Schema does not define mutations")
                    ])
            }
            rootType = m
        case .subscription:
            guard let s = schema.subscription else {
                return PrismGraphQLResult(
                    data: nil,
                    errors: [
                        PrismGraphQLError(message: "Schema does not define subscriptions")
                    ])
            }
            rootType = s
        }

        var errors: [PrismGraphQLError] = []
        let data = await resolveSelectionSet(
            selections: operation.selectionSet,
            objectType: rootType,
            parentValue: nil,
            context: context,
            variables: variables,
            schema: schema,
            path: [],
            errors: &errors
        )

        return PrismGraphQLResult(data: data, errors: errors)
    }

    private func resolveSelectionSet(
        selections: [PrismGraphQLSelection],
        objectType: PrismGraphQLObjectType,
        parentValue: (any Sendable)?,
        context: (any Sendable)?,
        variables: [String: Any],
        schema: PrismGraphQLSchema,
        path: [String],
        errors: inout [PrismGraphQLError]
    ) async -> [String: Any] {
        var result: [String: Any] = [:]

        for selection in selections {
            switch selection {
            case .field(let fieldSelection):
                let responseName = fieldSelection.responseName
                let fieldPath = path + [responseName]

                if fieldSelection.name == "__typename" {
                    result[responseName] = objectType.name
                    continue
                }

                if fieldSelection.name == "__schema" {
                    result[responseName] = resolveIntrospectionSchema(schema: schema, selection: fieldSelection)
                    continue
                }

                if fieldSelection.name == "__type" {
                    let typeName =
                        fieldSelection.arguments.first { $0.name == "name" }?.value.resolveVariables(variables)
                        as? String
                    result[responseName] = resolveIntrospectionType(
                        schema: schema, typeName: typeName, selection: fieldSelection)
                    continue
                }

                guard let field = objectType.fields[fieldSelection.name] else {
                    errors.append(
                        PrismGraphQLError(
                            message: "Field '\(fieldSelection.name)' not found on type '\(objectType.name)'",
                            path: fieldPath
                        ))
                    result[responseName] = NSNull()
                    continue
                }

                var args: [String: Any] = [:]
                for arg in fieldSelection.arguments {
                    args[arg.name] = arg.value.resolveVariables(variables)
                }

                let info = PrismGraphQLResolveInfo(
                    fieldName: fieldSelection.name,
                    arguments: args,
                    context: context,
                    parentValue: parentValue
                )

                do {
                    let value = try await field.resolve(info)

                    if !fieldSelection.selectionSet.isEmpty, let dictValue = value as? [String: Any] {
                        if case .object(let typeName) = unwrapType(field.type),
                            let nestedType = schema.types[typeName]
                        {
                            let nested = await resolveSelectionSet(
                                selections: fieldSelection.selectionSet,
                                objectType: nestedType,
                                parentValue: value,
                                context: context,
                                variables: variables,
                                schema: schema,
                                path: fieldPath,
                                errors: &errors
                            )
                            result[responseName] = nested
                        } else {
                            result[responseName] = dictValue
                        }
                    } else if !fieldSelection.selectionSet.isEmpty, let arrValue = value as? [[String: Any]] {
                        var resolvedArr: [[String: Any]] = []
                        let innerType = unwrapListType(field.type)
                        if case .object(let typeName) = innerType,
                            let nestedType = schema.types[typeName]
                        {
                            for (i, item) in arrValue.enumerated() {
                                let itemPath = fieldPath + ["\(i)"]
                                let nested = await resolveSelectionSet(
                                    selections: fieldSelection.selectionSet,
                                    objectType: nestedType,
                                    parentValue: nil,
                                    context: context,
                                    variables: variables,
                                    schema: schema,
                                    path: itemPath,
                                    errors: &errors
                                )
                                resolvedArr.append(nested)
                            }
                        } else {
                            resolvedArr = arrValue
                        }
                        result[responseName] = resolvedArr
                    } else {
                        result[responseName] = value ?? NSNull()
                    }
                } catch {
                    errors.append(
                        PrismGraphQLError(
                            message: error.localizedDescription,
                            path: fieldPath
                        ))
                    result[responseName] = NSNull()
                }

            case .fragmentSpread:
                break
            }
        }

        return result
    }

    private func unwrapType(_ type: PrismGraphQLType) -> PrismGraphQLType {
        switch type {
        case .nonNull(let inner): return unwrapType(inner)
        case .list(let inner): return unwrapType(inner)
        default: return type
        }
    }

    private func unwrapListType(_ type: PrismGraphQLType) -> PrismGraphQLType {
        switch type {
        case .nonNull(let inner): return unwrapListType(inner)
        case .list(let inner): return unwrapType(inner)
        default: return type
        }
    }

    // MARK: - Introspection

    private func resolveIntrospectionSchema(schema: PrismGraphQLSchema, selection: PrismGraphQLFieldSelection)
        -> [String: Any]
    {
        var result: [String: Any] = [:]
        for sub in selection.selectionSet {
            guard case .field(let f) = sub else { continue }
            switch f.name {
            case "queryType":
                result[f.responseName] = ["name": schema.query.name]
            case "mutationType":
                result[f.responseName] = schema.mutation.map { ["name": $0.name] as Any } ?? NSNull()
            case "subscriptionType":
                result[f.responseName] = schema.subscription.map { ["name": $0.name] as Any } ?? NSNull()
            case "types":
                result[f.responseName] = schema.types.values.map { type -> [String: Any] in
                    introspectObjectType(type, selection: f)
                }
            default:
                break
            }
        }
        return result
    }

    private func resolveIntrospectionType(
        schema: PrismGraphQLSchema, typeName: String?, selection: PrismGraphQLFieldSelection
    ) -> Any {
        guard let name = typeName, let type = schema.types[name] else { return NSNull() }
        return introspectObjectType(type, selection: selection)
    }

    private func introspectObjectType(_ type: PrismGraphQLObjectType, selection: PrismGraphQLFieldSelection) -> [String:
        Any]
    {
        var result: [String: Any] = [:]
        for sub in selection.selectionSet {
            guard case .field(let f) = sub else { continue }
            switch f.name {
            case "name":
                result[f.responseName] = type.name
            case "description":
                result[f.responseName] = type.description ?? NSNull()
            case "kind":
                result[f.responseName] = "OBJECT"
            case "fields":
                result[f.responseName] = type.fields.values.map { field -> [String: Any] in
                    var fieldDict: [String: Any] = ["name": field.name]
                    for sf in f.selectionSet {
                        guard case .field(let ff) = sf else { continue }
                        switch ff.name {
                        case "name": fieldDict["name"] = field.name
                        case "description": fieldDict["description"] = field.description ?? NSNull()
                        case "type": fieldDict["type"] = ["name": field.type.typeName]
                        case "isDeprecated": fieldDict["isDeprecated"] = field.deprecationReason != nil
                        case "deprecationReason": fieldDict["deprecationReason"] = field.deprecationReason ?? NSNull()
                        case "args":
                            fieldDict["args"] = field.args.map { arg -> [String: Any] in
                                [
                                    "name": arg.name, "type": ["name": arg.type.typeName],
                                    "description": arg.description ?? NSNull(),
                                ]
                            }
                        default: break
                        }
                    }
                    return fieldDict
                }
            default:
                break
            }
        }
        return result
    }
}
