//
//  PrismMultipartUpload.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// Builds a multipart/form-data request body from parts.
public struct PrismMultipartFormData: Sendable {
    private let boundary: String
    private var parts: [Part] = []

    private struct Part: Sendable {
        let headers: String
        let body: Data
    }

    /// Creates a multipart form data builder with a unique boundary.
    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }

    /// Appends binary data as a named file part.
    public mutating func append(
        data: Data,
        name: String,
        fileName: String,
        mimeType: String
    ) {
        var headers = "--\(boundary)\r\n"
        headers += "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n"
        headers += "Content-Type: \(mimeType)\r\n\r\n"
        parts.append(Part(headers: headers, body: data))
    }

    /// Appends a string value as a named form field.
    public mutating func append(string: String, name: String) {
        var headers = "--\(boundary)\r\n"
        headers += "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
        let body = Data(string.utf8)
        parts.append(Part(headers: headers, body: body))
    }

    /// Builds the final multipart body and content type string.
    public func build() -> (Data, String) {
        var body = Data()
        for part in parts {
            body.append(Data(part.headers.utf8))
            body.append(part.body)
            body.append(Data("\r\n".utf8))
        }
        body.append(Data("--\(boundary)--\r\n".utf8))
        let contentType = "multipart/form-data; boundary=\(boundary)"
        return (body, contentType)
    }
}

/// Tracks the progress of an upload operation.
public struct PrismUploadProgress: Sendable {
    /// The number of bytes uploaded so far.
    public let bytesUploaded: Int64
    /// The total number of bytes to upload.
    public let totalBytes: Int64

    /// The fraction of the upload that is complete (0.0 to 1.0).
    public var fractionCompleted: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytesUploaded) / Double(totalBytes)
    }

    /// Creates an upload progress value.
    public init(bytesUploaded: Int64, totalBytes: Int64) {
        self.bytesUploaded = bytesUploaded
        self.totalBytes = totalBytes
    }
}

/// Wraps a URLSession upload task with progress reporting via AsyncStream.
public actor PrismUploadTask {
    private let session: URLSession
    private let request: URLRequest
    private let data: Data

    /// Creates an upload task for the given request and data.
    public init(
        request: URLRequest,
        data: Data,
        session: URLSession = .shared
    ) {
        self.request = request
        self.data = data
        self.session = session
    }

    /// Starts the upload and returns a stream of progress updates.
    public func upload() -> AsyncStream<PrismUploadProgress> {
        let totalBytes = Int64(data.count)
        let request = self.request
        let data = self.data
        let session = self.session

        return AsyncStream { continuation in
            let delegate = UploadProgressDelegate(
                totalBytes: totalBytes,
                continuation: continuation
            )
            let delegateSession = URLSession(
                configuration: session.configuration,
                delegate: delegate,
                delegateQueue: nil
            )
            let task = delegateSession.uploadTask(with: request, from: data) { _, _, error in
                if error == nil {
                    continuation.yield(
                        PrismUploadProgress(
                            bytesUploaded: totalBytes,
                            totalBytes: totalBytes
                        )
                    )
                }
                continuation.finish()
                delegateSession.invalidateAndCancel()
            }
            task.resume()
        }
    }
}

/// Delegate that forwards upload byte counts to an AsyncStream continuation.
private final class UploadProgressDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let totalBytes: Int64
    private let continuation: AsyncStream<PrismUploadProgress>.Continuation

    init(
        totalBytes: Int64,
        continuation: AsyncStream<PrismUploadProgress>.Continuation
    ) {
        self.totalBytes = totalBytes
        self.continuation = continuation
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        continuation.yield(
            PrismUploadProgress(
                bytesUploaded: totalBytesSent,
                totalBytes: totalBytesExpectedToSend
            )
        )
    }
}
