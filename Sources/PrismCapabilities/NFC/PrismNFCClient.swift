import Foundation

// MARK: - NFC Tag Type

/// The type of NFC tag detected during a reader session.
public enum PrismNFCTagType: Sendable, CaseIterable {
    /// An NFC tag that supports NDEF messages.
    case ndefTag
    /// An ISO 7816-compatible smart card tag.
    case iso7816
    /// An ISO 15693 vicinity tag.
    case iso15693
    /// A FeliCa (Sony) tag.
    case felica
    /// A MIFARE Ultralight tag.
    case mifareUltralight
    /// A MIFARE DESFire tag.
    case mifareDesfire
}

// MARK: - NDEF Type Name Format

/// The type name format field of an NDEF record, per the NFC Forum specification.
public enum PrismNDEFTypeNameFormat: Sendable, CaseIterable {
    /// An empty record with no type or payload.
    case empty
    /// An NFC Forum well-known type (e.g., text or URI).
    case wellKnown
    /// A MIME media type as defined in RFC 2046.
    case media
    /// An absolute URI as defined in RFC 3986.
    case absoluteURI
    /// An NFC Forum external type.
    case external
    /// The type is unknown.
    case unknown
    /// The payload is an intermediate or final chunk of a chunked record.
    case unchanged
}

// MARK: - NDEF Record

/// A single record inside an NDEF message.
public struct PrismNDEFRecord: Sendable {
    /// The type name format indicating how to interpret the `type` field.
    public let typeNameFormat: PrismNDEFTypeNameFormat
    /// The record type (e.g. "T" for text, "U" for URI in well-known format).
    public let type: Data
    /// The payload data of the record.
    public let payload: Data
    /// An optional identifier for the record.
    public let identifier: Data

    /// Creates a new NDEF record with the given type name format, type, and payload.
    public init(typeNameFormat: PrismNDEFTypeNameFormat, type: Data, payload: Data, identifier: Data = Data()) {
        self.typeNameFormat = typeNameFormat
        self.type = type
        self.payload = payload
        self.identifier = identifier
    }
}

// MARK: - NDEF Message

/// An NDEF message composed of one or more records.
public struct PrismNDEFMessage: Sendable {
    /// The ordered list of NDEF records in this message.
    public let records: [PrismNDEFRecord]

    /// Creates a new NDEF message containing the given records.
    public init(records: [PrismNDEFRecord]) {
        self.records = records
    }
}

// MARK: - NFC Read Result

/// The result of reading an NFC tag, including tag type, NDEF message, and tag identifier.
public struct PrismNFCReadResult: Sendable {
    /// The type of NFC tag that was detected.
    public let tagType: PrismNFCTagType
    /// The NDEF message read from the tag, if available.
    public let message: PrismNDEFMessage?
    /// The unique identifier of the tag, if available.
    public let identifier: Data?

    /// Creates a new NFC read result with the given tag type, optional message, and identifier.
    public init(tagType: PrismNFCTagType, message: PrismNDEFMessage? = nil, identifier: Data? = nil) {
        self.tagType = tagType
        self.message = message
        self.identifier = identifier
    }
}

// MARK: - NFC Client

#if canImport(CoreNFC)
import CoreNFC

/// Observable client for reading and writing NFC tags using Core NFC.
///
/// Wraps `NFCNDEFReaderSession` and `NFCTagReaderSession` to provide
/// async/await APIs for NDEF read/write and ISO 7816 APDU exchange.
///
/// ```swift
/// let client = PrismNFCClient()
/// if client.isAvailable {
///     let result = try await client.readNDEF(alertMessage: "Hold near tag")
///     print(result.tagType)
/// }
/// ```
@MainActor @Observable
public final class PrismNFCClient {
    /// Whether NFC reading is available on this device.
    public var isAvailable: Bool {
        NFCNDEFReaderSession.readingAvailable
    }

    /// Creates a new NFC client.
    public init() {}

    /// Reads an NDEF message from a nearby NFC tag.
    ///
    /// - Parameter alertMessage: The message displayed on the NFC scanning sheet.
    /// - Returns: A `PrismNFCReadResult` containing the tag type, NDEF message, and identifier.
    /// - Throws: An error if no tag is found or the session is cancelled.
    public func readNDEF(alertMessage: String) async throws -> PrismNFCReadResult {
        try await withCheckedThrowingContinuation { continuation in
            let delegate = NDEFReaderDelegate { result in
                continuation.resume(with: result)
            }
            let session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: true)
            session.alertMessage = alertMessage
            // Keep delegate alive for the duration of the session
            objc_setAssociatedObject(session, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            session.begin()
        }
    }

    /// Writes an NDEF message to a nearby NFC tag.
    ///
    /// - Parameters:
    ///   - message: The NDEF message to write.
    ///   - alertMessage: The message displayed on the NFC scanning sheet.
    /// - Throws: An error if the tag is not writable or the session is cancelled.
    public func writeNDEF(message: PrismNDEFMessage, alertMessage: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let delegate = NDEFWriterDelegate(message: message) { result in
                continuation.resume(with: result)
            }
            let session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: false)
            session.alertMessage = alertMessage
            objc_setAssociatedObject(session, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            session.begin()
        }
    }

    /// Sends an ISO 7816 APDU SELECT command to a tag matching the given Application Identifier.
    ///
    /// - Parameters:
    ///   - aid: The Application Identifier (AID) data to select.
    ///   - alertMessage: The message displayed on the NFC scanning sheet.
    /// - Returns: The response data from the ISO 7816 tag.
    /// - Throws: An error if no ISO 7816 tag is found or the APDU exchange fails.
    public func readISO7816(aid: Data, alertMessage: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            let delegate = ISO7816ReaderDelegate(aid: aid) { result in
                continuation.resume(with: result)
            }
            let session = NFCTagReaderSession(pollingOption: .iso14443, delegate: delegate, queue: nil)
            session?.alertMessage = alertMessage
            if let session {
                objc_setAssociatedObject(session, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
                session.begin()
            } else {
                continuation.resume(throwing: NFCReaderError(.readerSessionInvalidationErrorSystemIsBusy))
            }
        }
    }
}

// MARK: - Private NDEF Reader Delegate

private final class NDEFReaderDelegate: NSObject, NFCNDEFReaderSessionDelegate, @unchecked Sendable {
    private let completion: (Result<PrismNFCReadResult, Error>) -> Void

    init(completion: @escaping (Result<PrismNFCReadResult, Error>) -> Void) {
        self.completion = completion
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Only report non-cancellation errors
        let nfcError = error as? NFCReaderError
        if nfcError?.code != .readerSessionInvalidationErrorFirstNDEFTagRead {
            completion(.failure(error))
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let nfcMessage = messages.first else {
            completion(.success(PrismNFCReadResult(tagType: .ndefTag)))
            return
        }

        let records = nfcMessage.records.map { record in
            PrismNDEFRecord(
                typeNameFormat: record.typeNameFormat.toPrism,
                type: record.type,
                payload: record.payload,
                identifier: record.identifier
            )
        }

        let result = PrismNFCReadResult(
            tagType: .ndefTag,
            message: PrismNDEFMessage(records: records)
        )
        completion(.success(result))
    }
}

// MARK: - Private NDEF Writer Delegate

private final class NDEFWriterDelegate: NSObject, NFCNDEFReaderSessionDelegate, @unchecked Sendable {
    private let message: PrismNDEFMessage
    private let completion: (Result<Void, Error>) -> Void

    init(message: PrismNDEFMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        self.message = message
        self.completion = completion
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        completion(.failure(error))
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No writable tag found.")
            return
        }

        session.connect(to: tag) { [weak self] error in
            guard let self else { return }
            if let error {
                session.invalidate(errorMessage: error.localizedDescription)
                completion(.failure(error))
                return
            }

            let nfcRecords = message.records.map { record in
                NFCNDEFPayload(
                    format: record.typeNameFormat.toNFC,
                    type: record.type,
                    identifier: record.identifier,
                    payload: record.payload
                )
            }
            let nfcMessage = NFCNDEFMessage(records: nfcRecords)

            tag.writeNDEF(nfcMessage) { [weak self] error in
                if let error {
                    session.invalidate(errorMessage: error.localizedDescription)
                    self?.completion(.failure(error))
                } else {
                    session.invalidate()
                    self?.completion(.success(()))
                }
            }
        }
    }
}

// MARK: - Private ISO 7816 Reader Delegate

private final class ISO7816ReaderDelegate: NSObject, NFCTagReaderSessionDelegate, @unchecked Sendable {
    private let aid: Data
    private let completion: (Result<Data, Error>) -> Void

    init(aid: Data, completion: @escaping (Result<Data, Error>) -> Void) {
        self.aid = aid
        self.completion = completion
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        completion(.failure(error))
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first, case .iso7816(let iso7816Tag) = tag else {
            session.invalidate(errorMessage: "No ISO 7816 tag found.")
            return
        }

        session.connect(to: tag) { [weak self] error in
            guard let self else { return }
            if let error {
                session.invalidate(errorMessage: error.localizedDescription)
                completion(.failure(error))
                return
            }

            let apdu = NFCISO7816APDU(
                instructionClass: 0x00,
                instructionCode: 0xA4,
                p1Parameter: 0x04,
                p2Parameter: 0x00,
                data: aid,
                expectedResponseLength: -1
            )

            iso7816Tag.sendCommand(apdu: apdu) { [weak self] data, _, _, error in
                if let error {
                    session.invalidate(errorMessage: error.localizedDescription)
                    self?.completion(.failure(error))
                } else {
                    session.invalidate()
                    self?.completion(.success(data))
                }
            }
        }
    }
}

// MARK: - NFCTypeNameFormat Conversion

private extension NFCTypeNameFormat {
    var toPrism: PrismNDEFTypeNameFormat {
        switch self {
        case .empty: .empty
        case .nfcWellKnown: .wellKnown
        case .media: .media
        case .absoluteURI: .absoluteURI
        case .nfcExternal: .external
        case .unknown: .unknown
        case .unchanged: .unchanged
        @unknown default: .unknown
        }
    }
}

private extension PrismNDEFTypeNameFormat {
    var toNFC: NFCTypeNameFormat {
        switch self {
        case .empty: .empty
        case .wellKnown: .nfcWellKnown
        case .media: .media
        case .absoluteURI: .absoluteURI
        case .external: .nfcExternal
        case .unknown: .unknown
        case .unchanged: .unchanged
        }
    }
}
#endif
