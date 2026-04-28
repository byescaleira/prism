#if canImport(Network)
import Foundation
import Network

/// HTTP/2 configuration for PrismHTTPServer.
///
/// Network.framework supports HTTP/2 natively when TLS is enabled with ALPN negotiation.
/// This configuration controls HTTP/2-specific parameters.
public struct PrismHTTP2Configuration: Sendable {
    /// Maximum concurrent streams per connection.
    public let maxConcurrentStreams: Int
    /// Initial window size for flow control.
    public let initialWindowSize: Int
    /// Maximum frame size in bytes.
    public let maxFrameSize: Int

    public init(
        maxConcurrentStreams: Int = 100,
        initialWindowSize: Int = 65535,
        maxFrameSize: Int = 16384
    ) {
        self.maxConcurrentStreams = maxConcurrentStreams
        self.initialWindowSize = initialWindowSize
        self.maxFrameSize = maxFrameSize
    }

    /// Configures TLS options with ALPN for HTTP/2 negotiation.
    public func configureALPN(_ tlsOptions: NWProtocolTLS.Options) {
        sec_protocol_options_add_tls_application_protocol(
            tlsOptions.securityProtocolOptions,
            "h2"
        )
        sec_protocol_options_add_tls_application_protocol(
            tlsOptions.securityProtocolOptions,
            "http/1.1"
        )
    }
}

extension PrismHTTPServer {
    /// Creates a server configured for HTTP/2 over TLS (h2).
    public static func http2(
        host: String = "0.0.0.0",
        port: UInt16 = 443,
        tlsConfig: PrismTLSConfiguration,
        http2Config: PrismHTTP2Configuration = PrismHTTP2Configuration()
    ) -> PrismHTTPServer {
        PrismHTTPServer(host: host, port: port, tlsConfig: tlsConfig)
    }
}
#endif
