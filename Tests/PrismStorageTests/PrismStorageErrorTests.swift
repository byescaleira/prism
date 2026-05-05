import Foundation
import Testing

@testable import PrismStorage

@Suite("StoreErr")
struct PrismStorageErrorTests {
    @Test("All errors have descriptions")
    func descriptions() {
        let errors: [PrismStorageError] = [
            .encodingFailed("test"), .decodingFailed("test"),
            .writeFailed("test"), .readFailed("test"),
            .deleteFailed("test"), .keyNotFound("test"),
            .diskFull, .migrationFailed("test"),
            .containerNotAvailable, .transactionFailed("test"),
            .compressionFailed, .decompressionFailed,
            .encryptionFailed, .decryptionFailed,
            .quotaExceeded(1024), .invalidConfiguration("test"),
        ]
        for error in errors {
            #expect(error.errorDescription != nil)
        }
    }

    @Test("Errors are equatable")
    func equatable() {
        #expect(PrismStorageError.diskFull == .diskFull)
        #expect(PrismStorageError.encodingFailed("a") == .encodingFailed("a"))
        #expect(PrismStorageError.encodingFailed("a") != .encodingFailed("b"))
    }

    @Test("All error cases count")
    func allCases() {
        let errors: [PrismStorageError] = [
            .encodingFailed(""), .decodingFailed(""),
            .writeFailed(""), .readFailed(""),
            .deleteFailed(""), .keyNotFound(""),
            .diskFull, .migrationFailed(""),
            .containerNotAvailable, .transactionFailed(""),
            .compressionFailed, .decompressionFailed,
            .encryptionFailed, .decryptionFailed,
            .quotaExceeded(0), .invalidConfiguration(""),
        ]
        #expect(errors.count == 16)
    }
}
