import Foundation

/// Errors emitted by the PrismServer module.
public enum PrismHTTPError: Error, Sendable {
    /// The server could not bind to the specified address.
    case bindFailed(String)
    /// A network connection could not be established.
    case connectionFailed(String)
    /// HTTP request parsing failed.
    case parsingFailed(String)
    /// The operation timed out.
    case timeout
    /// The server is already running and cannot be started again.
    case serverAlreadyRunning
    /// The server is not running.
    case serverNotRunning
    /// TLS configuration failed.
    case tlsConfigurationFailed(String)
    /// WebSocket upgrade handshake failed.
    case webSocketUpgradeFailed
    /// The requested file was not found on disk.
    case fileMissing(String)
}
