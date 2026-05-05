import Foundation
import Testing

@testable import PrismSecurity

@Suite("AuditEvt")
struct PrismSecurityEventTests {
    @Test("All event kinds available")
    func allKinds() {
        #expect(PrismSecurityEventKind.allCases.count == 24)
    }

    @Test("Event has unique ID")
    func uniqueID() {
        let e1 = PrismSecurityEvent(kind: .biometricSuccess, detail: "test")
        let e2 = PrismSecurityEvent(kind: .biometricSuccess, detail: "test")
        #expect(e1.id != e2.id)
    }

    @Test("Event stores metadata")
    func metadata() {
        let event = PrismSecurityEvent(
            kind: .keychainRead,
            detail: "read apiToken",
            metadata: ["key": "apiToken"]
        )
        #expect(event.metadata["key"] == "apiToken")
    }

    @Test("Event equality")
    func equality() {
        let e1 = PrismSecurityEvent(kind: .biometricSuccess, detail: "ok")
        let e2 = PrismSecurityEvent(kind: .biometricSuccess, detail: "ok")
        #expect(e1 != e2) // different IDs
    }
}

@Suite("AuditLog")
struct PrismSecurityAuditLogTests {
    @Test("Record and retrieve entries")
    func recordRetrieve() {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "ok"))
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "read"))

        #expect(log.count == 2)
        #expect(log.allEntries.count == 2)
    }

    @Test("Hash chain integrity passes")
    func integrityPass() {
        let log = PrismSecurityAuditLog()
        for i in 0..<10 {
            log.record(PrismSecurityEvent(kind: .keychainWrite, detail: "entry \(i)"))
        }
        #expect(log.verifyIntegrity())
    }

    @Test("First entry has empty previous hash")
    func firstEntry() {
        let log = PrismSecurityAuditLog()
        let entry = log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "first"))
        #expect(entry.previousHash.isEmpty)
        #expect(entry.sequence == 0)
    }

    @Test("Entries linked by hash")
    func hashChain() {
        let log = PrismSecurityAuditLog()
        let first = log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "1"))
        let second = log.record(PrismSecurityEvent(kind: .keychainRead, detail: "2"))
        #expect(second.previousHash == first.entryHash)
    }

    @Test("Filter by event kind")
    func filterByKind() {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "ok"))
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "read"))
        log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "ok2"))

        let biometric = log.entries(ofKind: .biometricSuccess)
        #expect(biometric.count == 2)
    }

    @Test("Recent entries returns latest")
    func recentEntries() {
        let log = PrismSecurityAuditLog()
        for i in 0..<20 {
            log.record(PrismSecurityEvent(kind: .keychainWrite, detail: "\(i)"))
        }
        let recent = log.recentEntries(5)
        #expect(recent.count == 5)
        #expect(recent.first?.event.detail == "15")
    }

    @Test("Max entries enforced")
    func maxEntries() {
        let log = PrismSecurityAuditLog(maxEntries: 5)
        for i in 0..<10 {
            log.record(PrismSecurityEvent(kind: .keychainWrite, detail: "\(i)"))
        }
        #expect(log.count == 5)
    }

    @Test("Clear removes all entries")
    func clear() {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "ok"))
        log.clear()
        #expect(log.count == 0)
    }

    @Test("Empty log passes integrity")
    func emptyIntegrity() {
        let log = PrismSecurityAuditLog()
        #expect(log.verifyIntegrity())
    }
}

@Suite("AuditExp")
struct PrismAuditExporterTests {
    @Test("Export JSON produces valid data")
    func exportJSON() throws {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "ok"))
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "read"))

        let exporter = PrismAuditExporter()
        let data = try exporter.exportJSON(log.allEntries)
        #expect(!data.isEmpty)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode([PrismAuditLogEntry].self, from: data)
        #expect(decoded.count == 2)
    }

    @Test("Export JSON string")
    func exportString() throws {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "test"))

        let exporter = PrismAuditExporter()
        let string = try exporter.exportJSONString(log.allEntries)
        #expect(string.contains("biometricSuccess"))
    }

    @Test("Export summary")
    func summary() {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "ok"))
        log.record(PrismSecurityEvent(kind: .biometricSuccess, detail: "ok2"))
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "read"))

        let exporter = PrismAuditExporter()
        let summary = exporter.exportSummary(log.allEntries)

        #expect(summary.totalEntries == 3)
        #expect(summary.eventCounts[.biometricSuccess] == 2)
        #expect(summary.eventCounts[.keychainRead] == 1)
    }
}
