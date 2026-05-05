import Foundation
import Testing

@testable import PrismServer

@Suite("PrismGraphQLType Tests")
struct PrismGraphQLTypeTests {

    @Test("String typeName")
    func stringType() {
        #expect(PrismGraphQLType.string.typeName == "String")
    }

    @Test("Int typeName")
    func intType() {
        #expect(PrismGraphQLType.int.typeName == "Int")
    }

    @Test("Float typeName")
    func floatType() {
        #expect(PrismGraphQLType.float.typeName == "Float")
    }

    @Test("Boolean typeName")
    func booleanType() {
        #expect(PrismGraphQLType.boolean.typeName == "Boolean")
    }

    @Test("ID typeName")
    func idType() {
        #expect(PrismGraphQLType.id.typeName == "ID")
    }

    @Test("NonNull typeName")
    func nonNullType() {
        #expect(PrismGraphQLType.nonNull(.string).typeName == "String!")
    }

    @Test("List typeName")
    func listType() {
        #expect(PrismGraphQLType.list(.int).typeName == "[Int]")
    }

    @Test("Object typeName")
    func objectType() {
        #expect(PrismGraphQLType.object("User").typeName == "User")
    }

    @Test("Enum typeName")
    func enumType() {
        #expect(PrismGraphQLType.enum("Status", ["ACTIVE", "INACTIVE"]).typeName == "Status")
    }

    @Test("Input typeName")
    func inputType() {
        #expect(PrismGraphQLType.input("UserInput").typeName == "UserInput")
    }

    @Test("isNonNull")
    func isNonNull() {
        #expect(PrismGraphQLType.nonNull(.string).isNonNull)
        #expect(!PrismGraphQLType.string.isNonNull)
    }
}

@Suite("PrismGraphQLParser Tests")
struct PrismGraphQLParserTests {

    @Test("Parses simple query")
    func simpleQuery() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ hello }")
        #expect(doc.operations.count == 1)
        let op = doc.firstOperation!
        #expect(op.operationType == .query)
        #expect(op.name == nil)
        #expect(op.selectionSet.count == 1)
        if case .field(let field) = op.selectionSet[0] {
            #expect(field.name == "hello")
            #expect(field.alias == nil)
        } else {
            #expect(Bool(false), "Expected field selection")
        }
    }

    @Test("Parses query with arguments")
    func queryWithArgs() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ user(id: \"1\") { name } }")
        let op = doc.firstOperation!
        if case .field(let field) = op.selectionSet[0] {
            #expect(field.name == "user")
            #expect(field.arguments.count == 1)
            #expect(field.arguments[0].name == "id")
            if case .string(let val) = field.arguments[0].value {
                #expect(val == "1")
            }
            #expect(field.selectionSet.count == 1)
        }
    }

    @Test("Parses named query")
    func namedQuery() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("query GetUser { user { name } }")
        let op = doc.firstOperation!
        #expect(op.operationType == .query)
        #expect(op.name == "GetUser")
    }

    @Test("Parses mutation")
    func mutation() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("mutation { createUser { id } }")
        let op = doc.firstOperation!
        #expect(op.operationType == .mutation)
    }

    @Test("Parses alias")
    func alias() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ h: hello }")
        let op = doc.firstOperation!
        if case .field(let field) = op.selectionSet[0] {
            #expect(field.alias == "h")
            #expect(field.name == "hello")
            #expect(field.responseName == "h")
        }
    }

    @Test("Parses boolean and null values")
    func valueTypes() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ field(a: true, b: false, c: null) }")
        if case .field(let field) = doc.firstOperation!.selectionSet[0] {
            #expect(field.arguments.count == 3)
            if case .boolean(let v) = field.arguments[0].value { #expect(v == true) }
            if case .boolean(let v) = field.arguments[1].value { #expect(v == false) }
            if case .null = field.arguments[2].value {} else { #expect(Bool(false), "Expected null") }
        }
    }

    @Test("Parses integer argument")
    func intArg() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ field(limit: 10) }")
        if case .field(let field) = doc.firstOperation!.selectionSet[0] {
            if case .int(let v) = field.arguments[0].value {
                #expect(v == 10)
            }
        }
    }
}

@Suite("PrismGraphQLExecutor Tests")
struct PrismGraphQLExecutorTests {

    @Test("Executes simple query")
    func simpleExecution() async throws {
        let helloField = PrismGraphQLField(
            name: "hello",
            type: .string,
            resolve: { _ in "world" }
        )
        let queryType = PrismGraphQLObjectType(name: "Query", fields: [helloField])
        let schema = PrismGraphQLSchema(query: queryType)

        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ hello }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)

        #expect(result.data?["hello"] as? String == "world")
        #expect(result.errors == nil)
    }

    @Test("Handles missing field error")
    func missingField() async throws {
        let queryType = PrismGraphQLObjectType(
            name: "Query",
            fields: [
                PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
            ])
        let schema = PrismGraphQLSchema(query: queryType)

        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ missing }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)

        #expect(result.errors != nil)
        #expect(result.errors!.count == 1)
    }

    @Test("Passes arguments to resolver")
    func resolverArguments() async throws {
        let field = PrismGraphQLField(
            name: "greet",
            type: .string,
            args: [PrismGraphQLArgument(name: "name", type: .string)],
            resolve: { info in
                let name: String = info.arg("name") ?? "stranger"
                return "Hello, \(name)!"
            }
        )
        let queryType = PrismGraphQLObjectType(name: "Query", fields: [field])
        let schema = PrismGraphQLSchema(query: queryType)

        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ greet(name: \"Alice\") }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)

        #expect(result.data?["greet"] as? String == "Hello, Alice!")
    }

    @Test("toJSON returns valid data")
    func resultToJSON() async throws {
        let field = PrismGraphQLField(name: "count", type: .int, resolve: { _ in 42 })
        let queryType = PrismGraphQLObjectType(name: "Query", fields: [field])
        let schema = PrismGraphQLSchema(query: queryType)

        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ count }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)

        let jsonData = result.toJSON()
        let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        let data = json?["data"] as? [String: Any]
        #expect(data?["count"] as? Int == 42)
    }

    @Test("Schema stores query type")
    func schemaQueryType() {
        let field = PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
        let queryType = PrismGraphQLObjectType(name: "Query", fields: [field])
        let schema = PrismGraphQLSchema(query: queryType)
        #expect(schema.query.name == "Query")
        #expect(schema.mutation == nil)
        #expect(schema.subscription == nil)
        #expect(schema.types["Query"] != nil)
    }
}
