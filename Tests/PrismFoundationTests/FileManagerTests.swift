import Foundation
import Testing

@testable import PrismFoundation

struct FileManagerTests {
    @Test
    func buildsPublicAndPrivatePathsInsideInjectedDirectory() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }

        let manager = PrismFileManager(documentsURL: directory)
        let publicPath = manager.path(with: "public.txt", privacy: .public)
        let privatePath = manager.path(with: "private.txt", privacy: .private)

        #expect(publicPath == directory.appendingPathComponent("public.txt"))
        #expect(privatePath == directory.appendingPathComponent(".private/private.txt"))
        #expect(FileManager.default.fileExists(atPath: directory.appendingPathComponent(".private").path()))
    }

    @Test
    func returnsNilWhenNoDocumentDirectoryExists() {
        let manager = PrismFileManager(documentsURL: nil)

        #expect(manager.path(with: "file.txt") == nil)
    }

    @Test
    func defaultInitializerBuildsPathsFromSystemDocumentsDirectory() {
        let manager = PrismFileManager()

        #expect(manager.path(with: "file.txt")?.lastPathComponent == "file.txt")
    }

    @Test
    func returnsNilWhenPrivateDirectoryCannotBeCreated() throws {
        let parent = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try Data().write(to: parent)
        defer { try? FileManager.default.removeItem(at: parent) }

        let manager = PrismFileManager(documentsURL: parent)

        #expect(manager.path(with: "file.txt", privacy: .private) == nil)
    }

    @Test
    func computesFileSizeAndFormatsBytes() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }

        let fileURL = directory.appendingPathComponent("file.bin")
        try Data(repeating: 0x41, count: 2048).write(to: fileURL)

        let manager = PrismFileManager(documentsURL: directory)
        let missingFileURL = directory.appendingPathComponent("missing.bin")
        let missingSizeManager = PrismFileManager(
            fileManager: MissingSizeAttributeFileManager(),
            documentsURL: directory
        )

        #expect(manager.size(at: fileURL) == manager.format(bytes: 2048))
        #expect(manager.size(at: missingFileURL) == manager.format(bytes: .zero))
        #expect(manager.size(at: nil) == manager.format(bytes: .zero))
        #expect(missingSizeManager.size(at: fileURL) == missingSizeManager.format(bytes: .zero))
    }

    @Test
    func filePrivacyRawValuesAreStable() {
        #expect(PrismFilePrivacy.public.rawValue.isEmpty)
        #expect(PrismFilePrivacy.private.rawValue == ".private")
    }
}
