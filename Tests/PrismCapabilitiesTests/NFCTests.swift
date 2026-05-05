import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - NFC Tag Type Tests

@Suite("PrismNFCTagType")
struct PrismNFCTagTypeTests {

    @Test("PrismNFCTagType has 6 cases")
    func tagTypeCaseCount() {
        #expect(PrismNFCTagType.allCases.count == 6)
    }

    @Test("PrismNFCTagType includes all expected cases")
    func tagTypeCases() {
        let cases = PrismNFCTagType.allCases
        #expect(cases.contains(.ndefTag))
        #expect(cases.contains(.iso7816))
        #expect(cases.contains(.iso15693))
        #expect(cases.contains(.felica))
        #expect(cases.contains(.mifareUltralight))
        #expect(cases.contains(.mifareDesfire))
    }
}

// MARK: - NDEF Type Name Format Tests

@Suite("PrismNDEFTypeNameFormat")
struct PrismNDEFTypeNameFormatTests {

    @Test("PrismNDEFTypeNameFormat has 7 cases")
    func typeNameFormatCaseCount() {
        #expect(PrismNDEFTypeNameFormat.allCases.count == 7)
    }

    @Test("PrismNDEFTypeNameFormat includes all expected cases")
    func typeNameFormatCases() {
        let cases = PrismNDEFTypeNameFormat.allCases
        #expect(cases.contains(.empty))
        #expect(cases.contains(.wellKnown))
        #expect(cases.contains(.media))
        #expect(cases.contains(.absoluteURI))
        #expect(cases.contains(.external))
        #expect(cases.contains(.unknown))
        #expect(cases.contains(.unchanged))
    }
}

// MARK: - NDEF Record Tests

@Suite("PrismNDEFRecord")
struct PrismNDEFRecordTests {

    @Test("PrismNDEFRecord stores properties correctly")
    func recordProperties() {
        let typeData = Data("T".utf8)
        let payloadData = Data("Hello NFC".utf8)
        let identifierData = Data([0x01, 0x02])

        let record = PrismNDEFRecord(
            typeNameFormat: .wellKnown,
            type: typeData,
            payload: payloadData,
            identifier: identifierData
        )
        #expect(record.typeNameFormat == .wellKnown)
        #expect(record.type == typeData)
        #expect(record.payload == payloadData)
        #expect(record.identifier == identifierData)
    }

    @Test("PrismNDEFRecord defaults identifier to empty data")
    func recordDefaultIdentifier() {
        let record = PrismNDEFRecord(
            typeNameFormat: .media,
            type: Data("text/plain".utf8),
            payload: Data("content".utf8)
        )
        #expect(record.identifier == Data())
    }

    @Test("PrismNDEFRecord with empty type name format")
    func recordEmptyFormat() {
        let record = PrismNDEFRecord(
            typeNameFormat: .empty,
            type: Data(),
            payload: Data()
        )
        #expect(record.typeNameFormat == .empty)
        #expect(record.type.isEmpty)
        #expect(record.payload.isEmpty)
    }
}

// MARK: - NDEF Message Tests

@Suite("PrismNDEFMessage")
struct PrismNDEFMessageTests {

    @Test("PrismNDEFMessage stores records correctly")
    func messageRecords() {
        let record1 = PrismNDEFRecord(
            typeNameFormat: .wellKnown,
            type: Data("U".utf8),
            payload: Data("https://apple.com".utf8)
        )
        let record2 = PrismNDEFRecord(
            typeNameFormat: .wellKnown,
            type: Data("T".utf8),
            payload: Data("Hello".utf8)
        )

        let message = PrismNDEFMessage(records: [record1, record2])
        #expect(message.records.count == 2)
        #expect(message.records[0].typeNameFormat == .wellKnown)
        #expect(message.records[1].payload == Data("Hello".utf8))
    }

    @Test("PrismNDEFMessage with empty records")
    func messageEmptyRecords() {
        let message = PrismNDEFMessage(records: [])
        #expect(message.records.isEmpty)
    }
}

// MARK: - NFC Read Result Tests

@Suite("PrismNFCReadResult")
struct PrismNFCReadResultTests {

    @Test("PrismNFCReadResult stores properties correctly")
    func readResultProperties() {
        let record = PrismNDEFRecord(
            typeNameFormat: .wellKnown,
            type: Data("T".utf8),
            payload: Data("Test".utf8)
        )
        let message = PrismNDEFMessage(records: [record])
        let identifier = Data([0xAA, 0xBB, 0xCC])

        let result = PrismNFCReadResult(
            tagType: .iso7816,
            message: message,
            identifier: identifier
        )
        #expect(result.tagType == .iso7816)
        #expect(result.message?.records.count == 1)
        #expect(result.identifier == identifier)
    }

    @Test("PrismNFCReadResult defaults message and identifier to nil")
    func readResultDefaults() {
        let result = PrismNFCReadResult(tagType: .ndefTag)
        #expect(result.message == nil)
        #expect(result.identifier == nil)
    }

    @Test("PrismNFCReadResult with each tag type")
    func readResultTagTypes() {
        let types: [PrismNFCTagType] = [.ndefTag, .iso7816, .iso15693, .felica, .mifareUltralight, .mifareDesfire]
        for tagType in types {
            let result = PrismNFCReadResult(tagType: tagType)
            #expect(result.tagType == tagType)
        }
    }
}
