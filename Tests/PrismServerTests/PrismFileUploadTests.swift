import Foundation
import Testing

@testable import PrismServer

@Suite("PrismUploadConfig Tests")
struct PrismUploadConfigTests {

    @Test("Default config values")
    func defaults() {
        let config = PrismUploadConfig()
        #expect(config.maxFileSize == 10_485_760)
        #expect(config.maxTotalSize == 52_428_800)
        #expect(config.allowedTypes.isEmpty)
    }

    @Test("Custom config values")
    func custom() {
        let config = PrismUploadConfig(
            maxFileSize: 1024,
            maxTotalSize: 4096,
            allowedTypes: ["image/png"]
        )
        #expect(config.maxFileSize == 1024)
        #expect(config.maxTotalSize == 4096)
        #expect(config.allowedTypes == ["image/png"])
    }
}

@Suite("PrismUploadedFile Tests")
struct PrismUploadedFileTests {

    @Test("data() reads file contents")
    func readData() throws {
        let path = makeTempFile(content: "hello world")
        let file = PrismUploadedFile(filename: "test.txt", contentType: "text/plain", size: 11, tempPath: path)

        let data = try file.data()
        #expect(String(data: data, encoding: .utf8) == "hello world")
        file.cleanup()
    }

    @Test("move() moves file to destination")
    func moveFile() throws {
        let path = makeTempFile(content: "moveme")
        let dest = NSTemporaryDirectory() + "prism_test_dest_\(UUID().uuidString)/moved.txt"
        let file = PrismUploadedFile(filename: "test.txt", contentType: "text/plain", size: 6, tempPath: path)

        try file.move(to: dest)
        #expect(!FileManager.default.fileExists(atPath: path))
        #expect(FileManager.default.fileExists(atPath: dest))

        try? FileManager.default.removeItem(atPath: dest)
        try? FileManager.default.removeItem(atPath: (dest as NSString).deletingLastPathComponent)
    }

    @Test("cleanup() deletes temp file")
    func cleanup() {
        let path = makeTempFile(content: "delete me")
        let file = PrismUploadedFile(filename: "test.txt", contentType: "text/plain", size: 9, tempPath: path)

        file.cleanup()
        #expect(!FileManager.default.fileExists(atPath: path))
    }
}

@Suite("PrismUploadResult Tests")
struct PrismUploadResultTests {

    @Test("file returns first uploaded file")
    func firstFile() {
        let f = PrismUploadedFile(filename: "a.txt", contentType: "text/plain", size: 1, tempPath: "/tmp/a")
        let result = PrismUploadResult(files: ["field": f], fields: [:])
        #expect(result.file?.filename == "a.txt")
    }

    @Test("file returns nil when empty")
    func noFile() {
        let result = PrismUploadResult(files: [:], fields: [:])
        #expect(result.file == nil)
    }

    @Test("cleanup removes all temp files")
    func cleanupAll() {
        let p1 = makeTempFile(content: "1")
        let p2 = makeTempFile(content: "2")
        let f1 = PrismUploadedFile(filename: "a.txt", contentType: "text/plain", size: 1, tempPath: p1)
        let f2 = PrismUploadedFile(filename: "b.txt", contentType: "text/plain", size: 1, tempPath: p2)

        let result = PrismUploadResult(files: ["a": f1, "b": f2], fields: [:])
        result.cleanup()

        #expect(!FileManager.default.fileExists(atPath: p1))
        #expect(!FileManager.default.fileExists(atPath: p2))
    }

    @Test("fields are preserved")
    func fieldsPreserved() {
        let result = PrismUploadResult(files: [:], fields: ["name": "John", "age": "30"])
        #expect(result.fields["name"] == "John")
        #expect(result.fields["age"] == "30")
    }
}

private func makeTempFile(content: String) -> String {
    let path = NSTemporaryDirectory() + "prism_test_\(UUID().uuidString).tmp"
    FileManager.default.createFile(atPath: path, contents: content.data(using: .utf8))
    return path
}
