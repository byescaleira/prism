#if canImport(SQLite3)
import Foundation
import SQLite3

/// Thread-safe SQLite database connection.
public actor PrismDatabase {
    nonisolated(unsafe) private var db: OpaquePointer?
    private let path: String

    /// Opens or creates a SQLite database at the given path. Use ":memory:" for in-memory.
    public init(path: String = ":memory:") throws {
        self.path = path
        var handle: OpaquePointer?
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX
        let result = sqlite3_open_v2(path, &handle, flags, nil)
        guard result == SQLITE_OK else {
            let msg = handle.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "Unknown"
            throw PrismDatabaseError.connectionFailed(msg)
        }
        self.db = handle
        sqlite3_busy_timeout(handle, 5000)
    }

    deinit {
        sqlite3_close(db)
    }

    /// Executes a SQL statement that doesn't return rows.
    @discardableResult
    public func execute(_ sql: String, parameters: [PrismDatabaseValue] = []) throws -> Int {
        let stmt = try prepare(sql, parameters: parameters)
        defer { sqlite3_finalize(stmt) }

        let result = sqlite3_step(stmt)
        guard result == SQLITE_DONE else {
            throw PrismDatabaseError.executionFailed(errorMessage)
        }
        return Int(sqlite3_changes(db))
    }

    /// Executes a query and returns all rows.
    public func query(_ sql: String, parameters: [PrismDatabaseValue] = []) throws -> [PrismRow] {
        let stmt = try prepare(sql, parameters: parameters)
        defer { sqlite3_finalize(stmt) }

        var rows: [PrismRow] = []
        let columnCount = sqlite3_column_count(stmt)
        let columnNames = (0..<columnCount).map { String(cString: sqlite3_column_name(stmt, $0)) }

        while sqlite3_step(stmt) == SQLITE_ROW {
            var values: [String: PrismDatabaseValue] = [:]
            for i in 0..<columnCount {
                let name = columnNames[Int(i)]
                values[name] = extractValue(stmt, column: i)
            }
            rows.append(PrismRow(values: values))
        }

        return rows
    }

    /// Executes a query and returns the first row.
    public func queryFirst(_ sql: String, parameters: [PrismDatabaseValue] = []) throws -> PrismRow? {
        try query(sql, parameters: parameters).first
    }

    /// Returns the last inserted row ID.
    public var lastInsertID: Int64 {
        sqlite3_last_insert_rowid(db)
    }

    /// Executes multiple statements within a transaction.
    public func transaction(_ block: @Sendable (isolated PrismDatabase) throws -> Void) throws {
        try execute("BEGIN TRANSACTION")
        do {
            try block(self)
            try execute("COMMIT")
        } catch {
            try execute("ROLLBACK")
            throw error
        }
    }

    // MARK: - Private

    private func prepare(_ sql: String, parameters: [PrismDatabaseValue]) throws -> OpaquePointer {
        var stmt: OpaquePointer?
        let result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        guard result == SQLITE_OK, let stmt else {
            throw PrismDatabaseError.prepareFailed(errorMessage)
        }

        for (i, param) in parameters.enumerated() {
            let idx = Int32(i + 1)
            switch param {
            case .null:
                sqlite3_bind_null(stmt, idx)
            case .int(let v):
                sqlite3_bind_int64(stmt, idx, Int64(v))
            case .double(let v):
                sqlite3_bind_double(stmt, idx, v)
            case .text(let v):
                sqlite3_bind_text(stmt, idx, v, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            case .blob(let v):
                _ = v.withUnsafeBytes { ptr in
                    sqlite3_bind_blob(stmt, idx, ptr.baseAddress, Int32(v.count), unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                }
            }
        }

        return stmt
    }

    private func extractValue(_ stmt: OpaquePointer, column: Int32) -> PrismDatabaseValue {
        switch sqlite3_column_type(stmt, column) {
        case SQLITE_NULL:
            return .null
        case SQLITE_INTEGER:
            return .int(Int(sqlite3_column_int64(stmt, column)))
        case SQLITE_FLOAT:
            return .double(sqlite3_column_double(stmt, column))
        case SQLITE_TEXT:
            return .text(String(cString: sqlite3_column_text(stmt, column)))
        case SQLITE_BLOB:
            let count = Int(sqlite3_column_bytes(stmt, column))
            if let ptr = sqlite3_column_blob(stmt, column) {
                return .blob(Data(bytes: ptr, count: count))
            }
            return .null
        default:
            return .null
        }
    }

    private var errorMessage: String {
        db.map { String(cString: sqlite3_errmsg($0)) } ?? "Unknown error"
    }
}

/// A value that can be stored in or retrieved from SQLite.
public enum PrismDatabaseValue: Sendable, Equatable {
    case null
    case int(Int)
    case double(Double)
    case text(String)
    case blob(Data)

    public var intValue: Int? {
        if case .int(let v) = self { return v }
        return nil
    }

    public var doubleValue: Double? {
        if case .double(let v) = self { return v }
        return nil
    }

    public var textValue: String? {
        if case .text(let v) = self { return v }
        return nil
    }

    public var blobValue: Data? {
        if case .blob(let v) = self { return v }
        return nil
    }

    public var isNull: Bool {
        if case .null = self { return true }
        return false
    }
}

/// A single row returned from a database query.
public struct PrismRow: Sendable {
    public let values: [String: PrismDatabaseValue]

    public subscript(_ column: String) -> PrismDatabaseValue {
        values[column] ?? .null
    }

    public func int(_ column: String) -> Int? { values[column]?.intValue }
    public func double(_ column: String) -> Double? { values[column]?.doubleValue }
    public func text(_ column: String) -> String? { values[column]?.textValue }
    public func blob(_ column: String) -> Data? { values[column]?.blobValue }
}

/// Database errors.
public enum PrismDatabaseError: Error, Sendable {
    case connectionFailed(String)
    case prepareFailed(String)
    case executionFailed(String)
    case migrationFailed(String)
    case modelNotFound
    case decodingFailed(String)
}
#endif
