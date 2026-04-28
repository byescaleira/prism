import Foundation

/// A file uploaded via multipart/form-data.
public struct PrismUploadedFile: Sendable {
    /// Original filename from the client.
    public let filename: String
    /// MIME type of the file.
    public let contentType: String
    /// Size in bytes.
    public let size: Int
    /// Path to the temporary file on disk.
    public let tempPath: String

    public init(filename: String, contentType: String, size: Int, tempPath: String) {
        self.filename = filename
        self.contentType = contentType
        self.size = size
        self.tempPath = tempPath
    }

    /// Reads the file contents into memory.
    public func data() throws -> Data {
        try Data(contentsOf: URL(fileURLWithPath: tempPath))
    }

    /// Moves the file to a permanent location.
    public func move(to destination: String) throws {
        let destDir = (destination as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: destDir, withIntermediateDirectories: true)
        try FileManager.default.moveItem(atPath: tempPath, toPath: destination)
    }

    /// Deletes the temporary file.
    public func cleanup() {
        try? FileManager.default.removeItem(atPath: tempPath)
    }
}

/// Configuration for file upload handling.
public struct PrismUploadConfig: Sendable {
    /// Maximum file size in bytes. Default 10 MB.
    public let maxFileSize: Int
    /// Maximum total upload size in bytes. Default 50 MB.
    public let maxTotalSize: Int
    /// Allowed MIME types. Empty = allow all.
    public let allowedTypes: [String]
    /// Directory for temporary files.
    public let tempDirectory: String

    public init(
        maxFileSize: Int = 10_485_760,
        maxTotalSize: Int = 52_428_800,
        allowedTypes: [String] = [],
        tempDirectory: String = NSTemporaryDirectory()
    ) {
        self.maxFileSize = maxFileSize
        self.maxTotalSize = maxTotalSize
        self.allowedTypes = allowedTypes
        self.tempDirectory = tempDirectory
    }
}

/// Errors during file upload processing.
public enum PrismUploadError: Error, Sendable {
    case fileTooLarge(String, Int)
    case totalSizeTooLarge(Int)
    case typeNotAllowed(String, String)
    case saveFailed(String)
}

/// Processes multipart uploads, saving file parts to disk.
public struct PrismUploadProcessor: Sendable {
    private let config: PrismUploadConfig

    public init(config: PrismUploadConfig = PrismUploadConfig()) {
        self.config = config
    }

    /// Processes a request's multipart body and returns uploaded files.
    public func process(_ request: PrismHTTPRequest) throws -> PrismUploadResult {
        let parts = try request.multipartParts()

        var files: [String: PrismUploadedFile] = [:]
        var fields: [String: String] = [:]
        var totalSize = 0

        for part in parts {
            if let filename = part.filename {
                totalSize += part.data.count

                guard totalSize <= config.maxTotalSize else {
                    throw PrismUploadError.totalSizeTooLarge(totalSize)
                }

                guard part.data.count <= config.maxFileSize else {
                    throw PrismUploadError.fileTooLarge(filename, part.data.count)
                }

                let mimeType = part.contentType ?? "application/octet-stream"
                if !config.allowedTypes.isEmpty && !config.allowedTypes.contains(mimeType) {
                    throw PrismUploadError.typeNotAllowed(filename, mimeType)
                }

                let tempName = UUID().uuidString + "_" + filename
                let tempPath = (config.tempDirectory as NSString).appendingPathComponent(tempName)

                guard FileManager.default.createFile(atPath: tempPath, contents: part.data) else {
                    throw PrismUploadError.saveFailed(filename)
                }

                files[part.name] = PrismUploadedFile(
                    filename: filename,
                    contentType: mimeType,
                    size: part.data.count,
                    tempPath: tempPath
                )
            } else {
                fields[part.name] = part.stringValue ?? ""
            }
        }

        return PrismUploadResult(files: files, fields: fields)
    }
}

/// Result of processing file uploads.
public struct PrismUploadResult: Sendable {
    /// Uploaded files keyed by field name.
    public let files: [String: PrismUploadedFile]
    /// Non-file form fields.
    public let fields: [String: String]

    /// Returns the first uploaded file.
    public var file: PrismUploadedFile? { files.values.first }

    /// Cleans up all temporary files.
    public func cleanup() {
        for file in files.values {
            file.cleanup()
        }
    }
}
