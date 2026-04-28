#if canImport(CloudKit)
import CloudKit

// MARK: - Cloud Value

/// A typed value that can be stored in a CloudKit record field.
public enum PrismCloudValue: Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case data(Data)
    case date(Date)
    case reference(String)
    case stringArray([String])
}

// MARK: - Cloud Record

/// A lightweight representation of a CloudKit record.
public struct PrismCloudRecord: Sendable {
    /// The unique record identifier.
    public let id: String
    /// The record type name.
    public let recordType: String
    /// The field values keyed by field name.
    public let fields: [String: PrismCloudValue]
    /// When the record was created.
    public let createdAt: Date?
    /// When the record was last modified.
    public let modifiedAt: Date?

    public init(id: String, recordType: String, fields: [String: PrismCloudValue], createdAt: Date? = nil, modifiedAt: Date? = nil) {
        self.id = id
        self.recordType = recordType
        self.fields = fields
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - Cloud Database

/// Which CloudKit database to target.
public enum PrismCloudDatabase: Sendable {
    case publicDB
    case privateDB
    case sharedDB
}

// MARK: - Account Status

/// The iCloud account status on this device.
public enum PrismCloudAccountStatus: Sendable, CaseIterable {
    case available
    case noAccount
    case restricted
    case couldNotDetermine
    case temporarilyUnavailable
}

// MARK: - CloudKit Client

/// Actor-isolated client for CloudKit record CRUD, queries, subscriptions, and account status.
public actor PrismCloudKitClient {
    private let container: CKContainer

    public init(containerIdentifier: String? = nil) {
        if let id = containerIdentifier {
            container = CKContainer(identifier: id)
        } else {
            container = CKContainer.default()
        }
    }

    /// Saves a record to the specified database and returns the saved record.
    public func save(record: PrismCloudRecord, database: PrismCloudDatabase) async throws -> PrismCloudRecord {
        let db = resolveDatabase(database)
        let ckRecord = toCKRecord(record)
        let saved = try await db.save(ckRecord)
        return fromCKRecord(saved)
    }

    /// Fetches a single record by its identifier from the specified database.
    public func fetch(recordID: String, database: PrismCloudDatabase) async throws -> PrismCloudRecord? {
        let db = resolveDatabase(database)
        let id = CKRecord.ID(recordName: recordID)
        let record = try await db.record(for: id)
        return fromCKRecord(record)
    }

    /// Deletes a record by its identifier from the specified database.
    public func delete(recordID: String, database: PrismCloudDatabase) async throws {
        let db = resolveDatabase(database)
        let id = CKRecord.ID(recordName: recordID)
        try await db.deleteRecord(withID: id)
    }

    /// Queries records of the given type using a predicate string.
    public func query(recordType: String, predicate: String = "TRUEPREDICATE", database: PrismCloudDatabase, limit: Int = 100) async throws -> [PrismCloudRecord] {
        let db = resolveDatabase(database)
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(format: predicate))
        let (results, _) = try await db.records(matching: query, resultsLimit: limit)
        return results.compactMap { _, result in
            try? result.get()
        }.map(fromCKRecord)
    }

    /// Creates a subscription for new records of the given type.
    public func subscribe(recordType: String, database: PrismCloudDatabase) async throws -> String {
        let db = resolveDatabase(database)
        let subscriptionID = "prism-\(recordType)-\(UUID().uuidString)"
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: NSPredicate(value: true),
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        _ = try await db.save(subscription)
        return subscriptionID
    }

    /// Returns the current iCloud account status.
    public func accountStatus() async -> PrismCloudAccountStatus {
        do {
            let status = try await container.accountStatus()
            return switch status {
            case .available: .available
            case .noAccount: .noAccount
            case .restricted: .restricted
            case .couldNotDetermine: .couldNotDetermine
            case .temporarilyUnavailable: .temporarilyUnavailable
            @unknown default: .couldNotDetermine
            }
        } catch {
            return .couldNotDetermine
        }
    }

    // MARK: - Private

    private func resolveDatabase(_ database: PrismCloudDatabase) -> CKDatabase {
        switch database {
        case .publicDB: container.publicCloudDatabase
        case .privateDB: container.privateCloudDatabase
        case .sharedDB: container.sharedCloudDatabase
        }
    }

    private func toCKRecord(_ record: PrismCloudRecord) -> CKRecord {
        let ckRecord = CKRecord(recordType: record.recordType, recordID: CKRecord.ID(recordName: record.id))
        for (key, value) in record.fields {
            switch value {
            case .string(let s): ckRecord[key] = s as CKRecordValue
            case .int(let i): ckRecord[key] = i as CKRecordValue
            case .double(let d): ckRecord[key] = d as CKRecordValue
            case .data(let data): ckRecord[key] = data as CKRecordValue
            case .date(let date): ckRecord[key] = date as CKRecordValue
            case .reference(let refID): ckRecord[key] = CKRecord.Reference(recordID: CKRecord.ID(recordName: refID), action: .none)
            case .stringArray(let arr): ckRecord[key] = arr as CKRecordValue
            }
        }
        return ckRecord
    }

    private func fromCKRecord(_ ckRecord: CKRecord) -> PrismCloudRecord {
        var fields: [String: PrismCloudValue] = [:]
        for key in ckRecord.allKeys() {
            if let s = ckRecord[key] as? String {
                fields[key] = .string(s)
            } else if let i = ckRecord[key] as? Int {
                fields[key] = .int(i)
            } else if let d = ckRecord[key] as? Double {
                fields[key] = .double(d)
            } else if let data = ckRecord[key] as? Data {
                fields[key] = .data(data)
            } else if let date = ckRecord[key] as? Date {
                fields[key] = .date(date)
            } else if let ref = ckRecord[key] as? CKRecord.Reference {
                fields[key] = .reference(ref.recordID.recordName)
            } else if let arr = ckRecord[key] as? [String] {
                fields[key] = .stringArray(arr)
            }
        }
        return PrismCloudRecord(
            id: ckRecord.recordID.recordName,
            recordType: ckRecord.recordType,
            fields: fields,
            createdAt: ckRecord.creationDate,
            modifiedAt: ckRecord.modificationDate
        )
    }
}
#endif
