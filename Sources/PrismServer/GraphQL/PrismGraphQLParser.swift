import Foundation

/// Recursive descent parser for GraphQL query strings.
public struct PrismGraphQLParser: Sendable {
    /// Creates a new `PrismGraphQLParser` with the specified configuration.
    public init() {}

    /// Parses the input and returns the result.
    public func parse(_ source: String) throws -> PrismGraphQLDocument {
        var tokenizer = Tokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        var parser = TokenParser(tokens: tokens)
        return try parser.parseDocument()
    }
}

// MARK: - Tokenizer

private enum Token: Sendable, Equatable {
    case leftBrace
    case rightBrace
    case leftParen
    case rightParen
    case leftBracket
    case rightBracket
    case colon
    case comma
    case bang
    case dollar
    case ellipsis
    case equals
    case name(String)
    case stringValue(String)
    case intValue(Int)
    case floatValue(Double)
    case eof
}

private struct Tokenizer {
    private let source: [Character]
    private var pos: Int = 0

    init(source: String) {
        self.source = Array(source)
    }

    mutating func tokenize() throws -> [Token] {
        var tokens: [Token] = []
        while pos < source.count {
            skipWhitespaceAndComments()
            guard pos < source.count else { break }

            let c = source[pos]
            switch c {
            case "{":
                tokens.append(.leftBrace)
                pos += 1
            case "}":
                tokens.append(.rightBrace)
                pos += 1
            case "(":
                tokens.append(.leftParen)
                pos += 1
            case ")":
                tokens.append(.rightParen)
                pos += 1
            case "[":
                tokens.append(.leftBracket)
                pos += 1
            case "]":
                tokens.append(.rightBracket)
                pos += 1
            case ":":
                tokens.append(.colon)
                pos += 1
            case ",":
                tokens.append(.comma)
                pos += 1
            case "!":
                tokens.append(.bang)
                pos += 1
            case "$":
                tokens.append(.dollar)
                pos += 1
            case "=":
                tokens.append(.equals)
                pos += 1
            case ".":
                if pos + 2 < source.count && source[pos + 1] == "." && source[pos + 2] == "." {
                    tokens.append(.ellipsis)
                    pos += 3
                } else {
                    throw PrismGraphQLExecutionError.parserError("Unexpected '.'")
                }
            case "\"":
                tokens.append(try readString())
            default:
                if c.isLetter || c == "_" {
                    tokens.append(readName())
                } else if c == "-" || c.isNumber {
                    tokens.append(try readNumber())
                } else {
                    throw PrismGraphQLExecutionError.parserError("Unexpected character: \(c)")
                }
            }
        }
        tokens.append(.eof)
        return tokens
    }

    private mutating func skipWhitespaceAndComments() {
        while pos < source.count {
            let c = source[pos]
            if c.isWhitespace || c == "," {
                pos += 1
            } else if c == "#" {
                while pos < source.count && source[pos] != "\n" { pos += 1 }
            } else {
                break
            }
        }
    }

    private mutating func readName() -> Token {
        let start = pos
        while pos < source.count && (source[pos].isLetter || source[pos].isNumber || source[pos] == "_") {
            pos += 1
        }
        return .name(String(source[start..<pos]))
    }

    private mutating func readString() throws -> Token {
        pos += 1  // skip opening quote
        var result = ""
        while pos < source.count && source[pos] != "\"" {
            if source[pos] == "\\" && pos + 1 < source.count {
                pos += 1
                switch source[pos] {
                case "n": result.append("\n")
                case "t": result.append("\t")
                case "\\": result.append("\\")
                case "\"": result.append("\"")
                default: result.append(source[pos])
                }
            } else {
                result.append(source[pos])
            }
            pos += 1
        }
        guard pos < source.count else {
            throw PrismGraphQLExecutionError.parserError("Unterminated string")
        }
        pos += 1  // skip closing quote
        return .stringValue(result)
    }

    private mutating func readNumber() throws -> Token {
        let start = pos
        if pos < source.count && source[pos] == "-" { pos += 1 }
        while pos < source.count && source[pos].isNumber { pos += 1 }

        if pos < source.count && source[pos] == "." {
            pos += 1
            while pos < source.count && source[pos].isNumber { pos += 1 }
            guard let value = Double(String(source[start..<pos])) else {
                throw PrismGraphQLExecutionError.parserError("Invalid float")
            }
            return .floatValue(value)
        }

        guard let value = Int(String(source[start..<pos])) else {
            throw PrismGraphQLExecutionError.parserError("Invalid integer")
        }
        return .intValue(value)
    }
}

// MARK: - Token Parser

private struct TokenParser {
    let tokens: [Token]
    var pos: Int = 0

    var current: Token { pos < tokens.count ? tokens[pos] : .eof }

    mutating func advance() { pos += 1 }

    mutating func expect(_ token: Token) throws {
        guard current == token else {
            throw PrismGraphQLExecutionError.parserError("Expected \(token), got \(current)")
        }
        advance()
    }

    func peek() -> Token { current }

    mutating func parseDocument() throws -> PrismGraphQLDocument {
        var operations: [PrismGraphQLOperation] = []

        while current != .eof {
            operations.append(try parseOperation())
        }

        if operations.isEmpty {
            throw PrismGraphQLExecutionError.parserError("Empty document")
        }

        return PrismGraphQLDocument(operations: operations)
    }

    mutating func parseOperation() throws -> PrismGraphQLOperation {
        if case .leftBrace = current {
            let selections = try parseSelectionSet()
            return PrismGraphQLOperation(
                operationType: .query, name: nil, selectionSet: selections, variableDefinitions: [])
        }

        guard case .name(let opType) = current else {
            throw PrismGraphQLExecutionError.parserError("Expected operation type")
        }
        advance()

        let operationType: PrismGraphQLOperation.OperationType
        switch opType {
        case "query": operationType = .query
        case "mutation": operationType = .mutation
        case "subscription": operationType = .subscription
        default:
            throw PrismGraphQLExecutionError.parserError("Unknown operation type: \(opType)")
        }

        var name: String?
        if case .name(let n) = current {
            name = n
            advance()
        }

        var variables: [PrismGraphQLVariableDefinition] = []
        if case .leftParen = current {
            variables = try parseVariableDefinitions()
        }

        let selections = try parseSelectionSet()
        return PrismGraphQLOperation(
            operationType: operationType, name: name, selectionSet: selections, variableDefinitions: variables)
    }

    mutating func parseVariableDefinitions() throws -> [PrismGraphQLVariableDefinition] {
        try expect(.leftParen)
        var defs: [PrismGraphQLVariableDefinition] = []
        while current != .rightParen && current != .eof {
            try expect(.dollar)
            guard case .name(let varName) = current else {
                throw PrismGraphQLExecutionError.parserError("Expected variable name")
            }
            advance()
            try expect(.colon)
            let typeName = try parseTypeRef()

            var defaultValue: PrismGraphQLValue?
            if case .equals = current {
                advance()
                defaultValue = try parseValue()
            }

            defs.append(PrismGraphQLVariableDefinition(name: varName, type: typeName, defaultValue: defaultValue))
        }
        try expect(.rightParen)
        return defs
    }

    mutating func parseTypeRef() throws -> String {
        var result = ""
        if case .leftBracket = current {
            advance()
            result = "[\(try parseTypeRef())]"
            try expect(.rightBracket)
        } else if case .name(let name) = current {
            result = name
            advance()
        } else {
            throw PrismGraphQLExecutionError.parserError("Expected type name")
        }
        if case .bang = current {
            result += "!"
            advance()
        }
        return result
    }

    mutating func parseSelectionSet() throws -> [PrismGraphQLSelection] {
        try expect(.leftBrace)
        var selections: [PrismGraphQLSelection] = []
        while current != .rightBrace && current != .eof {
            if case .ellipsis = current {
                advance()
                guard case .name(let fragmentName) = current else {
                    throw PrismGraphQLExecutionError.parserError("Expected fragment name after ...")
                }
                advance()
                selections.append(.fragmentSpread(fragmentName))
            } else {
                selections.append(.field(try parseFieldSelection()))
            }
        }
        try expect(.rightBrace)
        return selections
    }

    mutating func parseFieldSelection() throws -> PrismGraphQLFieldSelection {
        guard case .name(let firstName) = current else {
            throw PrismGraphQLExecutionError.parserError("Expected field name")
        }
        advance()

        var alias: String?
        var fieldName = firstName

        if case .colon = current {
            alias = firstName
            advance()
            guard case .name(let actualName) = current else {
                throw PrismGraphQLExecutionError.parserError("Expected field name after alias")
            }
            fieldName = actualName
            advance()
        }

        var arguments: [PrismGraphQLArgumentValue] = []
        if case .leftParen = current {
            arguments = try parseArguments()
        }

        var selectionSet: [PrismGraphQLSelection] = []
        if case .leftBrace = current {
            selectionSet = try parseSelectionSet()
        }

        return PrismGraphQLFieldSelection(
            alias: alias, name: fieldName, arguments: arguments, selectionSet: selectionSet)
    }

    mutating func parseArguments() throws -> [PrismGraphQLArgumentValue] {
        try expect(.leftParen)
        var args: [PrismGraphQLArgumentValue] = []
        while current != .rightParen && current != .eof {
            guard case .name(let argName) = current else {
                throw PrismGraphQLExecutionError.parserError("Expected argument name")
            }
            advance()
            try expect(.colon)
            let value = try parseValue()
            args.append(PrismGraphQLArgumentValue(name: argName, value: value))
        }
        try expect(.rightParen)
        return args
    }

    mutating func parseValue() throws -> PrismGraphQLValue {
        switch current {
        case .stringValue(let s):
            advance()
            return .string(s)
        case .intValue(let i):
            advance()
            return .int(i)
        case .floatValue(let f):
            advance()
            return .float(f)
        case .name(let n):
            advance()
            switch n {
            case "true": return .boolean(true)
            case "false": return .boolean(false)
            case "null": return .null
            default: return .enum(n)
            }
        case .dollar:
            advance()
            guard case .name(let varName) = current else {
                throw PrismGraphQLExecutionError.parserError("Expected variable name")
            }
            advance()
            return .variable(varName)
        case .leftBracket:
            advance()
            var items: [PrismGraphQLValue] = []
            while current != .rightBracket && current != .eof {
                items.append(try parseValue())
            }
            try expect(.rightBracket)
            return .list(items)
        case .leftBrace:
            advance()
            var fields: [String: PrismGraphQLValue] = [:]
            while current != .rightBrace && current != .eof {
                guard case .name(let key) = current else {
                    throw PrismGraphQLExecutionError.parserError("Expected object field name")
                }
                advance()
                try expect(.colon)
                fields[key] = try parseValue()
            }
            try expect(.rightBrace)
            return .object(fields)
        default:
            throw PrismGraphQLExecutionError.parserError("Unexpected value token: \(current)")
        }
    }
}
