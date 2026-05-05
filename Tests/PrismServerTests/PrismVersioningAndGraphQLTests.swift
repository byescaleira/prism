import Foundation
import Testing

@testable import PrismServer

// MARK: - PrismAPIVersion Extended Tests

@Suite("PrismAPIVersion Extended Tests")
struct PrismAPIVersionExtendedTests {

    @Test("Init with major only defaults minor to 0")
    func initMajorOnly() {
        let version = PrismAPIVersion(major: 1)
        #expect(version.major == 1)
        #expect(version.minor == 0)
    }

    @Test("Init with major and minor")
    func initMajorAndMinor() {
        let version = PrismAPIVersion(major: 2, minor: 3)
        #expect(version.major == 2)
        #expect(version.minor == 3)
    }

    @Test("Description is v1 when minor is 0")
    func descriptionMinorZero() {
        let version = PrismAPIVersion(major: 1)
        #expect(version.description == "v1")
    }

    @Test("Description is v1.2 when minor is greater than 0")
    func descriptionMinorNonZero() {
        let version = PrismAPIVersion(major: 1, minor: 2)
        #expect(version.description == "v1.2")
    }

    @Test("Parse v1 returns major 1 minor 0")
    func parseV1() {
        let version = PrismAPIVersion.parse("v1")
        #expect(version?.major == 1)
        #expect(version?.minor == 0)
    }

    @Test("Parse v1.2 returns major 1 minor 2")
    func parseV1Dot2() {
        let version = PrismAPIVersion.parse("v1.2")
        #expect(version?.major == 1)
        #expect(version?.minor == 2)
    }

    @Test("Parse uppercase V1 returns major 1 minor 0")
    func parseUppercaseV() {
        let version = PrismAPIVersion.parse("V1")
        #expect(version?.major == 1)
        #expect(version?.minor == 0)
    }

    @Test("Parse without prefix 1 returns major 1 minor 0")
    func parseWithoutPrefix() {
        let version = PrismAPIVersion.parse("1")
        #expect(version?.major == 1)
        #expect(version?.minor == 0)
    }

    @Test("Parse without prefix 1.2 returns major 1 minor 2")
    func parseWithoutPrefixDot() {
        let version = PrismAPIVersion.parse("1.2")
        #expect(version?.major == 1)
        #expect(version?.minor == 2)
    }

    @Test("Parse returns nil for invalid string abc")
    func parseInvalidAbc() {
        let version = PrismAPIVersion.parse("abc")
        #expect(version == nil)
    }

    @Test("Parse returns nil for empty string")
    func parseEmptyString() {
        let version = PrismAPIVersion.parse("")
        #expect(version == nil)
    }

    @Test("Comparable: v1 is less than v2")
    func comparableMajor() {
        let v1 = PrismAPIVersion(major: 1)
        let v2 = PrismAPIVersion(major: 2)
        #expect(v1 < v2)
    }

    @Test("Comparable: v1.1 is less than v1.2")
    func comparableMinor() {
        let v1 = PrismAPIVersion(major: 1, minor: 1)
        let v2 = PrismAPIVersion(major: 1, minor: 2)
        #expect(v1 < v2)
    }

    @Test("Equatable: same major and minor are equal")
    func sameVersionsAreEqual() {
        let a = PrismAPIVersion(major: 3, minor: 5)
        let b = PrismAPIVersion(major: 3, minor: 5)
        #expect(a == b)
    }

    @Test("Hashable: same versions produce same hash")
    func sameVersionsProduceSameHash() {
        let a = PrismAPIVersion(major: 2, minor: 1)
        let b = PrismAPIVersion(major: 2, minor: 1)
        #expect(a.hashValue == b.hashValue)

        var set = Set<PrismAPIVersion>()
        set.insert(a)
        set.insert(b)
        #expect(set.count == 1)
    }
}

// MARK: - PrismVersioningStrategy Tests

@Suite("PrismVersioningStrategy Extended Tests")
struct PrismVersioningStrategyExtendedTests {

    @Test("urlPrefix case exists")
    func urlPrefixCase() {
        let strategy: PrismVersioningStrategy = .urlPrefix
        if case .urlPrefix = strategy {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected .urlPrefix")
        }
    }

    @Test("header case with default Accept-Version")
    func headerDefault() {
        let strategy: PrismVersioningStrategy = .header()
        if case .header(let name) = strategy {
            #expect(name == "Accept-Version")
        } else {
            #expect(Bool(false), "Expected .header")
        }
    }

    @Test("queryParam case with default version")
    func queryParamDefault() {
        let strategy: PrismVersioningStrategy = .queryParam()
        if case .queryParam(let name) = strategy {
            #expect(name == "version")
        } else {
            #expect(Bool(false), "Expected .queryParam")
        }
    }
}

// MARK: - PrismVersionedRouter Tests

@Suite("PrismVersionedRouter Extended Tests")
struct PrismVersionedRouterExtendedTests {

    @Test("route registers handler and handle finds it")
    func routeAndHandle() async throws {
        var router = PrismVersionedRouter()
        let version = PrismAPIVersion(major: 1)
        router.route(version: version, .GET, "/users") { _ in
            PrismHTTPResponse(status: .ok)
        }

        var request = PrismHTTPRequest(method: .GET, uri: "/users")
        request.userInfo["apiVersion"] = "v1"
        let response = try await router.handle(request)
        #expect(response != nil)
        #expect(response?.status == .ok)
    }

    @Test("handle returns nil when no match")
    func handleNoMatch() async throws {
        var router = PrismVersionedRouter()
        let version = PrismAPIVersion(major: 1)
        router.route(version: version, .GET, "/users") { _ in
            PrismHTTPResponse(status: .ok)
        }

        var request = PrismHTTPRequest(method: .GET, uri: "/nonexistent")
        request.userInfo["apiVersion"] = "v1"
        let response = try await router.handle(request)
        #expect(response == nil)
    }

    @Test("Empty router handle returns nil")
    func emptyRouterReturnsNil() async throws {
        let router = PrismVersionedRouter()
        let request = PrismHTTPRequest(method: .GET, uri: "/anything")
        let response = try await router.handle(request)
        #expect(response == nil)
    }
}

// MARK: - PrismGraphQLAST Tests

@Suite("PrismGraphQLDocument Tests")
struct PrismGraphQLDocumentASTTests {

    @Test("Document stores operations")
    func documentOperations() {
        let op = PrismGraphQLOperation(
            operationType: .query,
            name: "GetUsers",
            selectionSet: [],
            variableDefinitions: []
        )
        let doc = PrismGraphQLDocument(operations: [op])
        #expect(doc.operations.count == 1)
        #expect(doc.firstOperation?.name == "GetUsers")
    }

    @Test("operation(named:) finds operation by name")
    func operationNamed() {
        let op1 = PrismGraphQLOperation(
            operationType: .query,
            name: "First",
            selectionSet: [],
            variableDefinitions: []
        )
        let op2 = PrismGraphQLOperation(
            operationType: .mutation,
            name: "Second",
            selectionSet: [],
            variableDefinitions: []
        )
        let doc = PrismGraphQLDocument(operations: [op1, op2])
        let found = doc.operation(named: "Second")
        #expect(found?.operationType == .mutation)
    }

    @Test("firstOperation returns nil for empty document")
    func emptyDocument() {
        let doc = PrismGraphQLDocument(operations: [])
        #expect(doc.firstOperation == nil)
    }
}

@Suite("PrismGraphQLOperation Tests")
struct PrismGraphQLOperationASTTests {

    @Test("OperationType enum cases exist")
    func operationTypes() {
        #expect(PrismGraphQLOperation.OperationType.query.rawValue == "query")
        #expect(PrismGraphQLOperation.OperationType.mutation.rawValue == "mutation")
        #expect(PrismGraphQLOperation.OperationType.subscription.rawValue == "subscription")
    }

    @Test("Operation stores all properties")
    func operationProperties() {
        let varDef = PrismGraphQLVariableDefinition(name: "id", type: "ID!", defaultValue: nil)
        let field = PrismGraphQLFieldSelection(alias: nil, name: "user", arguments: [], selectionSet: [])
        let op = PrismGraphQLOperation(
            operationType: .query,
            name: "GetUser",
            selectionSet: [.field(field)],
            variableDefinitions: [varDef]
        )
        #expect(op.operationType == .query)
        #expect(op.name == "GetUser")
        #expect(op.selectionSet.count == 1)
        #expect(op.variableDefinitions.count == 1)
    }
}

@Suite("PrismGraphQLVariableDefinition Tests")
struct PrismGraphQLVariableDefinitionASTTests {

    @Test("Stores name, type, and default value")
    func variableDefinitionProperties() {
        let varDef = PrismGraphQLVariableDefinition(
            name: "limit",
            type: "Int",
            defaultValue: .int(10)
        )
        #expect(varDef.name == "limit")
        #expect(varDef.type == "Int")
        if case .int(let value) = varDef.defaultValue {
            #expect(value == 10)
        } else {
            #expect(Bool(false), "Expected .int default value")
        }
    }

    @Test("Default value can be nil")
    func variableDefinitionNilDefault() {
        let varDef = PrismGraphQLVariableDefinition(name: "id", type: "ID!", defaultValue: nil)
        #expect(varDef.defaultValue == nil)
    }
}

@Suite("PrismGraphQLSelection Tests")
struct PrismGraphQLSelectionASTTests {

    @Test("Field case stores field selection")
    func fieldCase() {
        let field = PrismGraphQLFieldSelection(alias: nil, name: "name", arguments: [], selectionSet: [])
        let selection: PrismGraphQLSelection = .field(field)
        if case .field(let f) = selection {
            #expect(f.name == "name")
        } else {
            #expect(Bool(false), "Expected .field case")
        }
    }

    @Test("FragmentSpread case stores fragment name")
    func fragmentSpreadCase() {
        let selection: PrismGraphQLSelection = .fragmentSpread("UserFields")
        if case .fragmentSpread(let name) = selection {
            #expect(name == "UserFields")
        } else {
            #expect(Bool(false), "Expected .fragmentSpread case")
        }
    }
}

@Suite("PrismGraphQLFieldSelection Tests")
struct PrismGraphQLFieldSelectionASTTests {

    @Test("responseName returns alias when present")
    func responseNameWithAlias() {
        let field = PrismGraphQLFieldSelection(
            alias: "userName",
            name: "name",
            arguments: [],
            selectionSet: []
        )
        #expect(field.responseName == "userName")
    }

    @Test("responseName returns name when no alias")
    func responseNameWithoutAlias() {
        let field = PrismGraphQLFieldSelection(
            alias: nil,
            name: "email",
            arguments: [],
            selectionSet: []
        )
        #expect(field.responseName == "email")
    }

    @Test("Stores arguments and nested selections")
    func fieldWithArgumentsAndSelections() {
        let arg = PrismGraphQLArgumentValue(name: "id", value: .int(42))
        let nested = PrismGraphQLFieldSelection(alias: nil, name: "name", arguments: [], selectionSet: [])
        let field = PrismGraphQLFieldSelection(
            alias: nil,
            name: "user",
            arguments: [arg],
            selectionSet: [.field(nested)]
        )
        #expect(field.arguments.count == 1)
        #expect(field.arguments[0].name == "id")
        #expect(field.selectionSet.count == 1)
    }
}

@Suite("PrismGraphQLArgumentValue Tests")
struct PrismGraphQLArgumentValueASTTests {

    @Test("Stores name and value")
    func argumentProperties() {
        let arg = PrismGraphQLArgumentValue(name: "limit", value: .int(25))
        #expect(arg.name == "limit")
        if case .int(let v) = arg.value {
            #expect(v == 25)
        } else {
            #expect(Bool(false), "Expected .int value")
        }
    }
}

@Suite("PrismGraphQLValue Tests")
struct PrismGraphQLValueASTTests {

    @Test("String case stores string")
    func stringCase() {
        let value: PrismGraphQLValue = .string("hello")
        if case .string(let s) = value {
            #expect(s == "hello")
        } else {
            #expect(Bool(false), "Expected .string")
        }
    }

    @Test("Int case stores integer")
    func intCase() {
        let value: PrismGraphQLValue = .int(42)
        if case .int(let i) = value {
            #expect(i == 42)
        } else {
            #expect(Bool(false), "Expected .int")
        }
    }

    @Test("Float case stores double")
    func floatCase() {
        let value: PrismGraphQLValue = .float(3.14)
        if case .float(let f) = value {
            #expect(f == 3.14)
        } else {
            #expect(Bool(false), "Expected .float")
        }
    }

    @Test("Boolean case stores bool")
    func booleanCase() {
        let value: PrismGraphQLValue = .boolean(true)
        if case .boolean(let b) = value {
            #expect(b == true)
        } else {
            #expect(Bool(false), "Expected .boolean")
        }
    }

    @Test("Null case exists")
    func nullCase() {
        let value: PrismGraphQLValue = .null
        if case .null = value {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected .null")
        }
    }

    @Test("Variable case stores variable name")
    func variableCase() {
        let value: PrismGraphQLValue = .variable("userId")
        if case .variable(let name) = value {
            #expect(name == "userId")
        } else {
            #expect(Bool(false), "Expected .variable")
        }
    }

    @Test("List case stores array of values")
    func listCase() {
        let value: PrismGraphQLValue = .list([.int(1), .int(2), .int(3)])
        if case .list(let items) = value {
            #expect(items.count == 3)
        } else {
            #expect(Bool(false), "Expected .list")
        }
    }

    @Test("Object case stores dictionary of values")
    func objectCase() {
        let value: PrismGraphQLValue = .object(["key": .string("val")])
        if case .object(let dict) = value {
            #expect(dict.count == 1)
            if case .string(let s) = dict["key"] {
                #expect(s == "val")
            } else {
                #expect(Bool(false), "Expected .string in object")
            }
        } else {
            #expect(Bool(false), "Expected .object")
        }
    }

    @Test("Enum case stores enum value")
    func enumCase() {
        let value: PrismGraphQLValue = .enum("ACTIVE")
        if case .enum(let e) = value {
            #expect(e == "ACTIVE")
        } else {
            #expect(Bool(false), "Expected .enum")
        }
    }

    @Test("toAny converts string value")
    func toAnyString() {
        let value: PrismGraphQLValue = .string("test")
        let any = value.toAny()
        #expect(any as? String == "test")
    }

    @Test("toAny converts int value")
    func toAnyInt() {
        let value: PrismGraphQLValue = .int(7)
        let any = value.toAny()
        #expect(any as? Int == 7)
    }

    @Test("toAny converts null to NSNull")
    func toAnyNull() {
        let value: PrismGraphQLValue = .null
        let any = value.toAny()
        #expect(any is NSNull)
    }

    @Test("resolveVariables substitutes variable value")
    func resolveVariablesSubstitution() {
        let value: PrismGraphQLValue = .variable("name")
        let resolved = value.resolveVariables(["name": "Alice"])
        #expect(resolved as? String == "Alice")
    }

    @Test("resolveVariables returns NSNull for missing variable")
    func resolveVariablesMissing() {
        let value: PrismGraphQLValue = .variable("unknown")
        let resolved = value.resolveVariables([:])
        #expect(resolved is NSNull)
    }
}
