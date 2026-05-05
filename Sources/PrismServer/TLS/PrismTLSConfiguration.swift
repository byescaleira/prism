#if canImport(Network)
    import Foundation
    import Network

    /// TLS configuration for PrismHTTPServer using Network.framework.
    public struct PrismTLSConfiguration: Sendable {
        /// The path to the PKCS#12 identity file.
        public let identityPath: String?
        /// The passphrase for the identity file.
        public let passphrase: String?
        /// The minimum TLS protocol version.
        public let minimumVersion: TLSVersion
        /// Whether to enable HTTP Strict Transport Security.
        public let hstsEnabled: Bool
        /// The max-age value for HSTS in seconds.
        public let hstsMaxAge: Int

        /// Creates a new `PrismTLSConfiguration` with the specified configuration.
        public init(
            identityPath: String? = nil,
            passphrase: String? = nil,
            minimumVersion: TLSVersion = .tlsv12,
            hstsEnabled: Bool = true,
            hstsMaxAge: Int = 31_536_000
        ) {
            self.identityPath = identityPath
            self.passphrase = passphrase
            self.minimumVersion = minimumVersion
            self.hstsEnabled = hstsEnabled
            self.hstsMaxAge = hstsMaxAge
        }

        /// Creates an NWProtocolTLS.Options from this configuration.
        func makeOptions() throws -> NWProtocolTLS.Options {
            let options = NWProtocolTLS.Options()

            if let identityPath {
                guard let identityData = FileManager.default.contents(atPath: identityPath) else {
                    throw PrismHTTPError.tlsConfigurationFailed("Cannot read identity file at \(identityPath)")
                }

                let importOptions: [String: Any] = passphrase.map { [kSecImportExportPassphrase as String: $0] } ?? [:]

                var items: CFArray?
                let status = SecPKCS12Import(
                    identityData as CFData,
                    importOptions as CFDictionary,
                    &items
                )

                guard status == errSecSuccess,
                    let itemArray = items as? [[String: Any]],
                    let firstItem = itemArray.first,
                    let identity = firstItem[kSecImportItemIdentity as String]
                else {
                    throw PrismHTTPError.tlsConfigurationFailed("Failed to import PKCS#12 identity (status: \(status))")
                }

                let secIdentity = identity as! SecIdentity
                sec_protocol_options_set_local_identity(
                    options.securityProtocolOptions,
                    sec_identity_create(secIdentity)!
                )
            }

            sec_protocol_options_set_min_tls_protocol_version(
                options.securityProtocolOptions,
                minimumVersion.nwVersion
            )

            return options
        }
    }

    /// Supported TLS protocol versions.
    public enum TLSVersion: Sendable {
        case tlsv10
        case tlsv11
        case tlsv12
        case tlsv13

        var nwVersion: tls_protocol_version_t {
            switch self {
            case .tlsv10: .TLSv10
            case .tlsv11: .TLSv11
            case .tlsv12: .TLSv12
            case .tlsv13: .TLSv13
            }
        }
    }

    /// Middleware that adds HSTS headers to responses.
    public struct PrismHSTSMiddleware: PrismMiddleware {
        private let maxAge: Int
        private let includeSubDomains: Bool
        private let preload: Bool

        /// Creates a new `PrismHSTSMiddleware` with the specified configuration.
        public init(maxAge: Int = 31_536_000, includeSubDomains: Bool = true, preload: Bool = false) {
            self.maxAge = maxAge
            self.includeSubDomains = includeSubDomains
            self.preload = preload
        }

        /// Handles the request and returns a response.
        public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws
            -> PrismHTTPResponse
        {
            var response = try await next(request)

            var value = "max-age=\(maxAge)"
            if includeSubDomains { value += "; includeSubDomains" }
            if preload { value += "; preload" }

            response.headers.set(name: "Strict-Transport-Security", value: value)
            return response
        }
    }

    /// Middleware that adds common security headers.
    public struct PrismSecurityHeadersMiddleware: PrismMiddleware {

        /// Creates a new `PrismSecurityHeadersMiddleware` with the specified configuration.
        public init() {}

        /// Handles the request and returns a response.
        public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws
            -> PrismHTTPResponse
        {
            var response = try await next(request)
            response.headers.set(name: "X-Content-Type-Options", value: "nosniff")
            response.headers.set(name: "X-Frame-Options", value: "DENY")
            response.headers.set(name: "X-XSS-Protection", value: "1; mode=block")
            response.headers.set(name: "Referrer-Policy", value: "strict-origin-when-cross-origin")
            return response
        }
    }
#endif
