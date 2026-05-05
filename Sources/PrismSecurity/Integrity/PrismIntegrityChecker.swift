import Foundation

#if canImport(Darwin)
    import Darwin
#endif

/// Detects jailbreak, debugger, simulator, and reverse engineering indicators.
public struct PrismIntegrityChecker: Sendable {
    public init() {}

    /// Runs all integrity checks and returns any violations found.
    public func checkAll() -> [PrismIntegrityViolation] {
        var violations: [PrismIntegrityViolation] = []

        if isJailbroken() {
            violations.append(PrismIntegrityViolation(kind: .jailbreak, detail: "Jailbreak indicators detected"))
        }
        if isDebuggerAttached() {
            violations.append(PrismIntegrityViolation(kind: .debuggerAttached, detail: "Debugger is attached"))
        }
        if isSimulator() {
            violations.append(PrismIntegrityViolation(kind: .simulator, detail: "Running in simulator"))
        }
        if hasReverseEngineeringTools() {
            violations.append(PrismIntegrityViolation(kind: .reverseEngineering, detail: "Reverse engineering tools detected"))
        }

        return violations
    }

    /// Whether the environment passes all integrity checks.
    public var isSecure: Bool {
        checkAll().isEmpty
    }

    // MARK: - Jailbreak Detection

    /// Checks for common jailbreak indicators.
    public func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            return checkSuspiciousPaths()
                || checkWritableSystemPaths()
                || checkSuspiciousURLSchemes()
                || checkDyldInjection()
        #endif
    }

    private func checkSuspiciousPaths() -> Bool {
        let paths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/usr/sbin/sshd",
            "/usr/bin/ssh",
            "/usr/libexec/sftp-server",
            "/etc/apt",
            "/private/var/lib/apt",
            "/private/var/stash",
            "/private/var/tmp/cydia.log",
            "/var/cache/apt",
            "/var/lib/cydia",
            "/usr/bin/cycript",
            "/usr/local/bin/cycript",
            "/usr/lib/libcycript.dylib",
        ]
        return paths.contains { FileManager.default.fileExists(atPath: $0) }
    }

    private func checkWritableSystemPaths() -> Bool {
        let testPath = "/private/jailbreak_test_\(UUID().uuidString)"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }

    private func checkSuspiciousURLSchemes() -> Bool {
        #if canImport(UIKit)
            let schemes = ["cydia://", "sileo://", "zbra://", "undecimus://"]
            return schemes.contains { scheme in
                guard let url = URL(string: scheme) else { return false }
                return UIApplication.shared.canOpenURL(url)
            }
        #else
            return false
        #endif
    }

    private func checkDyldInjection() -> Bool {
        let suspiciousVars = [
            "DYLD_INSERT_LIBRARIES",
            "DYLD_FORCE_FLAT_NAMESPACE",
            "_MSSafeMode",
        ]
        return suspiciousVars.contains { ProcessInfo.processInfo.environment[$0] != nil }
    }

    // MARK: - Debugger Detection

    /// Checks if a debugger is currently attached via sysctl.
    public func isDebuggerAttached() -> Bool {
        #if canImport(Darwin)
            var info = kinfo_proc()
            var size = MemoryLayout<kinfo_proc>.stride
            var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
            let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
            guard result == 0 else { return false }
            return (info.kp_proc.p_flag & P_TRACED) != 0
        #else
            return false
        #endif
    }

    // MARK: - Simulator Detection

    /// Whether running in a simulator.
    public func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    // MARK: - Reverse Engineering Tools

    /// Checks for common reverse engineering tools.
    public func hasReverseEngineeringTools() -> Bool {
        let toolPaths = [
            "/usr/bin/frida-server",
            "/usr/local/bin/frida",
            "/usr/bin/objection",
            "/usr/local/bin/objection",
        ]
        return toolPaths.contains { FileManager.default.fileExists(atPath: $0) }
    }
}
