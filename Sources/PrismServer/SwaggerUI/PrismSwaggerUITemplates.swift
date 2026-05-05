import Foundation

// MARK: - OpenAPI Schema Types

/// OpenAPI data types for schema definitions.
public enum PrismOpenAPIType: String, Sendable {
    case string, integer, number, boolean, array, object
}

/// An OpenAPI schema definition describing a data model.
public struct PrismOpenAPISchema: Sendable {
    /// The type.
    public let type: PrismOpenAPIType
    /// The properties.
    public let properties: [(String, PrismOpenAPIProperty)]
    /// The required.
    public let required: [String]
    /// The items.
    public let items: PrismOpenAPIProperty?
    /// The description.
    public let description: String?

    /// Creates a new `PrismOpenAPISchema` with the specified configuration.
    public init(
        type: PrismOpenAPIType,
        properties: [(String, PrismOpenAPIProperty)] = [],
        required: [String] = [],
        items: PrismOpenAPIProperty? = nil,
        description: String? = nil
    ) {
        self.type = type
        self.properties = properties
        self.required = required
        self.items = items
        self.description = description
    }

    /// Returns the JSON schema representation of an object type.
    public static func object(
        _ properties: [(String, PrismOpenAPIProperty)], required: [String] = [], description: String? = nil
    ) -> PrismOpenAPISchema {
        PrismOpenAPISchema(type: .object, properties: properties, required: required, description: description)
    }

    /// Returns the JSON schema representation of an array type.
    public static func array(of items: PrismOpenAPIProperty, description: String? = nil) -> PrismOpenAPISchema {
        PrismOpenAPISchema(type: .array, items: items, description: description)
    }

    package func toDict() -> [String: Any] {
        var dict: [String: Any] = ["type": type.rawValue]
        if let description { dict["description"] = description }
        if !properties.isEmpty {
            var props: [String: Any] = [:]
            for (name, prop) in properties {
                props[name] = prop.toDict()
            }
            dict["properties"] = props
        }
        if !required.isEmpty { dict["required"] = required }
        if let items { dict["items"] = items.toDict() }
        return dict
    }
}

/// An OpenAPI property definition with type, format, and description.
public struct PrismOpenAPIProperty: Sendable {
    /// The type.
    public let type: PrismOpenAPIType
    /// The format.
    public let format: String?
    /// The description.
    public let description: String?
    /// The enum values.
    public let enumValues: [String]?
    /// The nullable.
    public let nullable: Bool

    /// Creates a new `PrismOpenAPIProperty` with the specified configuration.
    public init(
        type: PrismOpenAPIType, format: String? = nil, description: String? = nil, enumValues: [String]? = nil,
        nullable: Bool = false
    ) {
        self.type = type
        self.format = format
        self.description = description
        self.enumValues = enumValues
        self.nullable = nullable
    }

    /// Returns the JSON schema for a string property with optional format.
    public static func string(_ description: String? = nil, format: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .string, format: format, description: description)
    }

    /// Returns the JSON schema for an integer property.
    public static func integer(_ description: String? = nil, format: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .integer, format: format ?? "int64", description: description)
    }

    /// Returns the JSON schema for a floating-point number property.
    public static func number(_ description: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .number, description: description)
    }

    /// Returns the JSON schema for a boolean property.
    public static func boolean(_ description: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .boolean, description: description)
    }

    package func toDict() -> [String: Any] {
        var dict: [String: Any] = ["type": type.rawValue]
        if let format { dict["format"] = format }
        if let description { dict["description"] = description }
        if let enumValues { dict["enum"] = enumValues }
        if nullable { dict["nullable"] = true }
        return dict
    }
}

// MARK: - Route Metadata

/// An OpenAPI parameter definition for query, path, or header parameters.
public struct PrismOpenAPIParameter: Sendable {
    /// The location of the parameter in the HTTP request.
    public enum Location: String, Sendable { case path, query, header }

    /// The name.
    public let name: String
    /// The location.
    public let location: Location
    /// The description.
    public let description: String?
    /// The required.
    public let required: Bool
    /// The type.
    public let type: PrismOpenAPIType

    /// Creates a new `Location` with the specified configuration.
    public init(
        name: String, in location: Location, description: String? = nil, required: Bool = false,
        type: PrismOpenAPIType = .string
    ) {
        self.name = name
        self.location = location
        self.description = description
        self.required = location == .path ? true : required
        self.type = type
    }

    package func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "in": location.rawValue,
            "required": self.required,
            "schema": ["type": type.rawValue],
        ]
        if let description { dict["description"] = description }
        return dict
    }
}

/// Represents a OpenAPIResponseSpec.
public struct PrismOpenAPIResponseSpec: Sendable {
    /// The status code.
    public let statusCode: Int
    /// The description.
    public let description: String
    /// The schema.
    public let schema: PrismOpenAPISchema?
    /// The content type.
    public let contentType: String

    /// Creates a new `PrismOpenAPIResponseSpec` with the specified configuration.
    public init(
        statusCode: Int, description: String, schema: PrismOpenAPISchema? = nil,
        contentType: String = "application/json"
    ) {
        self.statusCode = statusCode
        self.description = description
        self.schema = schema
        self.contentType = contentType
    }

    package func toDict() -> [String: Any] {
        var dict: [String: Any] = ["description": description]
        if let schema {
            dict["content"] = [contentType: ["schema": schema.toDict()]]
        }
        return dict
    }
}

/// Metadata describing an API route for OpenAPI documentation generation.
public struct PrismRouteMetadata: Sendable {
    /// The summary.
    public let summary: String?
    /// The description.
    public let description: String?
    /// The tags.
    public let tags: [String]
    /// The parameters.
    public let parameters: [PrismOpenAPIParameter]
    /// The request body.
    public let requestBody: PrismOpenAPISchema?
    /// The responses.
    public let responses: [PrismOpenAPIResponseSpec]
    /// The deprecated.
    public let deprecated: Bool

    /// Creates a new `PrismRouteMetadata` with the specified configuration.
    public init(
        summary: String? = nil,
        description: String? = nil,
        tags: [String] = [],
        parameters: [PrismOpenAPIParameter] = [],
        requestBody: PrismOpenAPISchema? = nil,
        responses: [PrismOpenAPIResponseSpec] = [],
        deprecated: Bool = false
    ) {
        self.summary = summary
        self.description = description
        self.tags = tags
        self.parameters = parameters
        self.requestBody = requestBody
        self.responses = responses
        self.deprecated = deprecated
    }
}
