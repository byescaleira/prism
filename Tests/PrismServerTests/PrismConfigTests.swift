import Testing
import Foundation
@testable import PrismServer

@Suite("PrismConfig Tests")
struct PrismConfigTests {

    @Test("Get returns value")
    func getValue() {
        let config = PrismConfig(values: ["KEY": "value"])
        #expect(config.get("KEY") == "value")
    }

    @Test("Get returns nil for missing key")
    func getMissing() {
        let config = PrismConfig(values: [:])
        #expect(config.get("MISSING") == nil)
    }

    @Test("Get with default returns default when missing")
    func getDefault() {
        let config = PrismConfig(values: [:])
        #expect(config.get("MISSING", default: "fallback") == "fallback")
    }

    @Test("Get with default returns value when present")
    func getDefaultPresent() {
        let config = PrismConfig(values: ["KEY": "val"])
        #expect(config.get("KEY", default: "fallback") == "val")
    }

    @Test("Require returns value when present")
    func requirePresent() throws {
        let config = PrismConfig(values: ["KEY": "val"])
        let value = try config.require("KEY")
        #expect(value == "val")
    }

    @Test("Require throws for missing key")
    func requireMissing() {
        let config = PrismConfig(values: [:])
        #expect(throws: PrismConfigError.self) {
            _ = try config.require("MISSING")
        }
    }

    @Test("GetInt parses integer")
    func getInt() {
        let config = PrismConfig(values: ["PORT": "3000"])
        #expect(config.getInt("PORT") == 3000)
    }

    @Test("GetInt returns nil for non-integer")
    func getIntInvalid() {
        let config = PrismConfig(values: ["PORT": "abc"])
        #expect(config.getInt("PORT") == nil)
    }

    @Test("GetInt returns nil for missing")
    func getIntMissing() {
        let config = PrismConfig(values: [:])
        #expect(config.getInt("PORT") == nil)
    }

    @Test("GetInt with default")
    func getIntDefault() {
        let config = PrismConfig(values: [:])
        #expect(config.getInt("PORT", default: 8080) == 8080)
    }

    @Test("GetBool true values")
    func getBoolTrue() {
        for val in ["true", "1", "yes", "TRUE", "Yes"] {
            let config = PrismConfig(values: ["FLAG": val])
            #expect(config.getBool("FLAG") == true)
        }
    }

    @Test("GetBool false values")
    func getBoolFalse() {
        for val in ["false", "0", "no", "FALSE", "No"] {
            let config = PrismConfig(values: ["FLAG": val])
            #expect(config.getBool("FLAG") == false)
        }
    }

    @Test("GetBool returns nil for invalid")
    func getBoolInvalid() {
        let config = PrismConfig(values: ["FLAG": "maybe"])
        #expect(config.getBool("FLAG") == nil)
    }

    @Test("GetBool with default")
    func getBoolDefault() {
        let config = PrismConfig(values: [:])
        #expect(config.getBool("FLAG", default: true) == true)
    }

    @Test("GetDouble parses double")
    func getDouble() {
        let config = PrismConfig(values: ["RATE": "3.14"])
        #expect(config.getDouble("RATE") == 3.14)
    }

    @Test("GetDouble returns nil for missing")
    func getDoubleMissing() {
        let config = PrismConfig(values: [:])
        #expect(config.getDouble("RATE") == nil)
    }

    @Test("Environment defaults to development")
    func defaultEnvironment() {
        let config = PrismConfig(values: [:])
        #expect(config.environment == "development")
        #expect(config.isDevelopment == true)
        #expect(config.isProduction == false)
    }

    @Test("Production environment")
    func productionEnvironment() {
        let config = PrismConfig(values: ["PRISM_ENV": "production"])
        #expect(config.environment == "production")
        #expect(config.isProduction == true)
        #expect(config.isDevelopment == false)
    }

    @Test("Port defaults to 8080")
    func defaultPort() {
        let config = PrismConfig(values: [:])
        #expect(config.port == 8080)
    }

    @Test("Port from config")
    func customPort() {
        let config = PrismConfig(values: ["PORT": "3000"])
        #expect(config.port == 3000)
    }

    @Test("Host defaults to 0.0.0.0")
    func defaultHost() {
        let config = PrismConfig(values: [:])
        #expect(config.host == "0.0.0.0")
    }

    @Test("Host from config")
    func customHost() {
        let config = PrismConfig(values: ["HOST": "127.0.0.1"])
        #expect(config.host == "127.0.0.1")
    }

    @Test("Keys returns all keys")
    func keys() {
        let config = PrismConfig(values: ["A": "1", "B": "2"])
        #expect(Set(config.keys) == Set(["A", "B"]))
    }

    @Test("FromEnvironment includes process env")
    func fromEnvironment() {
        let config = PrismConfig.fromEnvironment()
        #expect(config.get("PATH") != nil)
    }

    @Test("FromEnvironment overrides take precedence")
    func fromEnvironmentOverrides() {
        let config = PrismConfig.fromEnvironment(overrides: ["CUSTOM_KEY": "custom_value"])
        #expect(config.get("CUSTOM_KEY") == "custom_value")
    }

    @Test("Load parses .env file")
    func loadEnvFile() throws {
        let tempDir = NSTemporaryDirectory()
        let envPath = (tempDir as NSString).appendingPathComponent("test_\(UUID().uuidString).env")
        let content = """
        APP_NAME=Prism
        APP_PORT=9090
        # This is a comment
        APP_DEBUG="true"
        APP_SECRET='mysecret'
        """
        try content.write(toFile: envPath, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: envPath) }

        let config = PrismConfig.load(path: envPath)
        #expect(config.get("APP_NAME") == "Prism")
        #expect(config.get("APP_PORT") == "9090")
        #expect(config.get("APP_DEBUG") == "true")
        #expect(config.get("APP_SECRET") == "mysecret")
    }

    @Test("Load ignores comments and blank lines")
    func loadIgnoresComments() throws {
        let tempDir = NSTemporaryDirectory()
        let envPath = (tempDir as NSString).appendingPathComponent("test_\(UUID().uuidString).env")
        let content = """
        # Comment line
        KEY=value
        """
        try content.write(toFile: envPath, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: envPath) }

        let config = PrismConfig.load(path: envPath)
        #expect(config.get("KEY") == "value")
    }

    @Test("Load missing file still works with env")
    func loadMissingFile() {
        let config = PrismConfig.load(path: "/nonexistent/.env")
        #expect(config.get("PATH") != nil)
    }
}
