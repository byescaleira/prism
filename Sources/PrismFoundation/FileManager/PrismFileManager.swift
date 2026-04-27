//
//  PrismFileManager.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation

/// File manager with public and private directory support.
///
/// Thread-safe: all stored properties are immutable after init, and `FileManager`
/// is itself thread-safe for the directory and attribute operations used here.
public struct PrismFileManager: @unchecked Sendable {
    private let fileManager: FileManager
    private let documentsURL: URL?

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.documentsURL =
            fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
    }

    public init(
        fileManager: FileManager = .default,
        documentsURL: URL?
    ) {
        self.fileManager = fileManager
        self.documentsURL = documentsURL
    }

    public func path(
        with name: String,
        privacy: PrismFilePrivacy = .public
    ) -> URL? {
        guard let documentsURL else { return nil }

        switch privacy {
        case .public:
            return documentsURL.appendingPathComponent(name)

        case .private:
            let privateURL = documentsURL.appendingPathComponent(privacy.rawValue)
            do {
                try fileManager.createDirectory(
                    at: privateURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                return nil
            }
            return privateURL.appendingPathComponent(name)
        }
    }

    public func size(at path: URL?) -> String {
        guard let path,
            let attributes = try? fileManager.attributesOfItem(atPath: path.path())
        else { return format(bytes: .zero) }
        let fileSize = attributes[.size] as? Int64 ?? 0
        return format(bytes: fileSize)
    }

    func format(bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file

        return formatter.string(fromByteCount: bytes)
    }
}
