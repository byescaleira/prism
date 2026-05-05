import Foundation

// MARK: - Email Types

/// An email address with an optional display name.
public struct PrismEmailAddress: Sendable, Equatable {
    /// The email.
    public let email: String
    /// The name.
    public let name: String?

    /// Creates a new `PrismEmailAddress` with the specified configuration.
    public init(_ email: String, name: String? = nil) {
        self.email = email
        self.name = name
    }

    /// The formatted.
    public var formatted: String {
        if let name {
            return "\(name) <\(email)>"
        }
        return email
    }
}

/// A file attachment for an email with filename, MIME type, and binary data.
public struct PrismEmailAttachment: Sendable {
    /// The filename.
    public let filename: String
    /// The mime type.
    public let mimeType: String
    /// The data.
    public let data: Data

    /// Creates a new `PrismEmailAttachment` with the specified configuration.
    public init(filename: String, mimeType: String, data: Data) {
        self.filename = filename
        self.mimeType = mimeType
        self.data = data
    }
}

/// A fully composed email with sender, recipients, subject, body, and attachments.
public struct PrismEmail: Sendable {
    /// The from.
    public let from: PrismEmailAddress
    /// The to.
    public let to: [PrismEmailAddress]
    /// The cc.
    public let cc: [PrismEmailAddress]
    /// The bcc.
    public let bcc: [PrismEmailAddress]
    /// The subject.
    public let subject: String
    /// The text body.
    public let textBody: String?
    /// The html body.
    public let htmlBody: String?
    /// The attachments.
    public let attachments: [PrismEmailAttachment]
    /// The reply to.
    public let replyTo: PrismEmailAddress?
    /// The headers.
    public let headers: [(String, String)]

    /// Creates a new `PrismEmail` with the specified configuration.
    public init(
        from: PrismEmailAddress,
        to: [PrismEmailAddress],
        cc: [PrismEmailAddress] = [],
        bcc: [PrismEmailAddress] = [],
        subject: String,
        textBody: String? = nil,
        htmlBody: String? = nil,
        attachments: [PrismEmailAttachment] = [],
        replyTo: PrismEmailAddress? = nil,
        headers: [(String, String)] = []
    ) {
        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.subject = subject
        self.textBody = textBody
        self.htmlBody = htmlBody
        self.attachments = attachments
        self.replyTo = replyTo
        self.headers = headers
    }
}

// MARK: - Email Builder

/// Builder for constructing Email instances.
public struct PrismEmailBuilder: Sendable {
    private var from: PrismEmailAddress?
    private var to: [PrismEmailAddress] = []
    private var cc: [PrismEmailAddress] = []
    private var bcc: [PrismEmailAddress] = []
    private var subject: String = ""
    private var textBody: String?
    private var htmlBody: String?
    private var attachments: [PrismEmailAttachment] = []
    private var replyTo: PrismEmailAddress?
    private var headers: [(String, String)] = []

    /// Creates a new `PrismEmailBuilder` with the specified configuration.
    public init() {}

    /// Sets the sender email address.
    public func from(_ email: String, name: String? = nil) -> PrismEmailBuilder {
        var copy = self
        copy.from = PrismEmailAddress(email, name: name)
        return copy
    }

    /// Adds a recipient email address.
    public func to(_ email: String, name: String? = nil) -> PrismEmailBuilder {
        var copy = self
        copy.to.append(PrismEmailAddress(email, name: name))
        return copy
    }

    /// Adds a carbon copy recipient.
    public func cc(_ email: String, name: String? = nil) -> PrismEmailBuilder {
        var copy = self
        copy.cc.append(PrismEmailAddress(email, name: name))
        return copy
    }

    /// Adds a blind carbon copy recipient.
    public func bcc(_ email: String, name: String? = nil) -> PrismEmailBuilder {
        var copy = self
        copy.bcc.append(PrismEmailAddress(email, name: name))
        return copy
    }

    /// Sets the email subject line.
    public func subject(_ subject: String) -> PrismEmailBuilder {
        var copy = self
        copy.subject = subject
        return copy
    }

    /// Sets the plain-text email body.
    public func text(_ body: String) -> PrismEmailBuilder {
        var copy = self
        copy.textBody = body
        return copy
    }

    /// Sets the HTML email body.
    public func html(_ body: String) -> PrismEmailBuilder {
        var copy = self
        copy.htmlBody = body
        return copy
    }

    /// Attaches a file with the given filename, MIME type, and data.
    public func attach(filename: String, mimeType: String, data: Data) -> PrismEmailBuilder {
        var copy = self
        copy.attachments.append(PrismEmailAttachment(filename: filename, mimeType: mimeType, data: data))
        return copy
    }

    /// Sets the reply-to address.
    public func replyTo(_ email: String, name: String? = nil) -> PrismEmailBuilder {
        var copy = self
        copy.replyTo = PrismEmailAddress(email, name: name)
        return copy
    }

    /// Adds a custom header to the email.
    public func header(_ name: String, _ value: String) -> PrismEmailBuilder {
        var copy = self
        copy.headers.append((name, value))
        return copy
    }

    /// Validates and builds the configured email.
    public func build() throws -> PrismEmail {
        guard let from else { throw PrismMailerError.missingFrom }
        guard !to.isEmpty else { throw PrismMailerError.missingRecipients }
        guard !subject.isEmpty else { throw PrismMailerError.missingSubject }
        guard textBody != nil || htmlBody != nil else { throw PrismMailerError.missingBody }

        return PrismEmail(
            from: from, to: to, cc: cc, bcc: bcc,
            subject: subject, textBody: textBody, htmlBody: htmlBody,
            attachments: attachments, replyTo: replyTo, headers: headers
        )
    }
}

// MARK: - MIME Builder

/// Builder for constructing MIME instances.
public struct PrismMIMEBuilder: Sendable {
    private static func generateBoundary() -> String {
        "PrismBoundary-\(UUID().uuidString)"
    }

    /// Builds a complete MIME message string from the given email.
    public static func buildMessage(_ email: PrismEmail) -> String {
        var message = ""

        message += "From: \(email.from.formatted)\r\n"
        message += "To: \(email.to.map(\.formatted).joined(separator: ", "))\r\n"
        if !email.cc.isEmpty {
            message += "Cc: \(email.cc.map(\.formatted).joined(separator: ", "))\r\n"
        }
        message += "Subject: \(encodedSubject(email.subject))\r\n"
        if let replyTo = email.replyTo {
            message += "Reply-To: \(replyTo.formatted)\r\n"
        }
        message += "MIME-Version: 1.0\r\n"
        message += "Date: \(rfc2822Date())\r\n"
        message += "Message-ID: <\(UUID().uuidString)@prism.local>\r\n"

        for (name, value) in email.headers {
            message += "\(name): \(value)\r\n"
        }

        let hasAttachments = !email.attachments.isEmpty
        let hasMultipleBodies = email.textBody != nil && email.htmlBody != nil

        if hasAttachments {
            let mixedBoundary = generateBoundary()
            message += "Content-Type: multipart/mixed; boundary=\"\(mixedBoundary)\"\r\n\r\n"

            if hasMultipleBodies {
                let altBoundary = generateBoundary()
                message += "--\(mixedBoundary)\r\n"
                message += "Content-Type: multipart/alternative; boundary=\"\(altBoundary)\"\r\n\r\n"
                message += textPart(email.textBody!, boundary: altBoundary)
                message += htmlPart(email.htmlBody!, boundary: altBoundary)
                message += "--\(altBoundary)--\r\n"
            } else if let text = email.textBody {
                message += "--\(mixedBoundary)\r\n"
                message += "Content-Type: text/plain; charset=utf-8\r\n"
                message += "Content-Transfer-Encoding: 8bit\r\n\r\n"
                message += text + "\r\n"
            } else if let html = email.htmlBody {
                message += "--\(mixedBoundary)\r\n"
                message += "Content-Type: text/html; charset=utf-8\r\n"
                message += "Content-Transfer-Encoding: 8bit\r\n\r\n"
                message += html + "\r\n"
            }

            for attachment in email.attachments {
                message += "--\(mixedBoundary)\r\n"
                message += "Content-Type: \(attachment.mimeType); name=\"\(attachment.filename)\"\r\n"
                message += "Content-Disposition: attachment; filename=\"\(attachment.filename)\"\r\n"
                message += "Content-Transfer-Encoding: base64\r\n\r\n"
                message += attachment.data.base64EncodedString(options: .lineLength76Characters) + "\r\n"
            }
            message += "--\(mixedBoundary)--\r\n"
        } else if hasMultipleBodies {
            let altBoundary = generateBoundary()
            message += "Content-Type: multipart/alternative; boundary=\"\(altBoundary)\"\r\n\r\n"
            message += textPart(email.textBody!, boundary: altBoundary)
            message += htmlPart(email.htmlBody!, boundary: altBoundary)
            message += "--\(altBoundary)--\r\n"
        } else if let text = email.textBody {
            message += "Content-Type: text/plain; charset=utf-8\r\n"
            message += "Content-Transfer-Encoding: 8bit\r\n\r\n"
            message += text + "\r\n"
        } else if let html = email.htmlBody {
            message += "Content-Type: text/html; charset=utf-8\r\n"
            message += "Content-Transfer-Encoding: 8bit\r\n\r\n"
            message += html + "\r\n"
        }

        return message
    }

    private static func textPart(_ text: String, boundary: String) -> String {
        var part = "--\(boundary)\r\n"
        part += "Content-Type: text/plain; charset=utf-8\r\n"
        part += "Content-Transfer-Encoding: 8bit\r\n\r\n"
        part += text + "\r\n"
        return part
    }

    private static func htmlPart(_ html: String, boundary: String) -> String {
        var part = "--\(boundary)\r\n"
        part += "Content-Type: text/html; charset=utf-8\r\n"
        part += "Content-Transfer-Encoding: 8bit\r\n\r\n"
        part += html + "\r\n"
        return part
    }

    private static func encodedSubject(_ subject: String) -> String {
        let needsEncoding = subject.contains(where: { $0.asciiValue == nil })
        if needsEncoding {
            let encoded = Data(subject.utf8).base64EncodedString()
            return "=?utf-8?B?\(encoded)?="
        }
        return subject
    }

    private static func rfc2822Date() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
}

// MARK: - SMTP Configuration

/// Configuration options for SMTP.
public struct PrismSMTPConfig: Sendable {
    /// The host.
    public let host: String
    /// The port.
    public let port: Int
    /// The username.
    public let username: String?
    /// The password.
    public let password: String?
    /// The use t l s.
    public let useTLS: Bool
    /// The connection timeout.
    public let connectionTimeout: TimeInterval

    /// Creates a new `PrismSMTPConfig` with the specified configuration.
    public init(
        host: String,
        port: Int = 587,
        username: String? = nil,
        password: String? = nil,
        useTLS: Bool = true,
        connectionTimeout: TimeInterval = 30
    ) {
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.useTLS = useTLS
        self.connectionTimeout = connectionTimeout
    }
}

// MARK: - SMTP Auth

/// Authentication methods supported by the SMTP client.
public enum PrismSMTPAuthMethod: String, Sendable {
    case plain = "PLAIN"
    case login = "LOGIN"
}

// MARK: - Mailer Actor

/// SMTP-based email delivery service.
public actor PrismMailerService {
    private let config: PrismSMTPConfig
    private let authMethod: PrismSMTPAuthMethod

    /// Creates a new `PrismMailerService` with the specified configuration.
    public init(config: PrismSMTPConfig, authMethod: PrismSMTPAuthMethod = .plain) {
        self.config = config
        self.authMethod = authMethod
    }

    /// Generates the SMTP command sequence for sending the email.
    public func buildSMTPCommands(for email: PrismEmail) -> [String] {
        var commands: [String] = []
        commands.append("EHLO \(config.host)")

        if let username = config.username, let password = config.password {
            switch authMethod {
            case .plain:
                let credentials = "\0\(username)\0\(password)"
                let encoded = Data(credentials.utf8).base64EncodedString()
                commands.append("AUTH PLAIN \(encoded)")
            case .login:
                commands.append("AUTH LOGIN")
                commands.append(Data(username.utf8).base64EncodedString())
                commands.append(Data(password.utf8).base64EncodedString())
            }
        }

        commands.append("MAIL FROM:<\(email.from.email)>")
        let allRecipients = email.to + email.cc + email.bcc
        for recipient in allRecipients {
            commands.append("RCPT TO:<\(recipient.email)>")
        }
        commands.append("DATA")

        let message = PrismMIMEBuilder.buildMessage(email)
        commands.append(message + "\r\n.")
        commands.append("QUIT")

        return commands
    }

    /// Validates an email address format and returns whether it is valid.
    public func validateEmail(_ email: PrismEmail) -> [String] {
        var errors: [String] = []
        if email.to.isEmpty { errors.append("No recipients") }
        if email.subject.isEmpty { errors.append("Empty subject") }
        if email.textBody == nil && email.htmlBody == nil { errors.append("No body") }
        for addr in email.to + email.cc + email.bcc {
            if !isValidEmailFormat(addr.email) {
                errors.append("Invalid email: \(addr.email)")
            }
        }
        if !isValidEmailFormat(email.from.email) {
            errors.append("Invalid from email: \(email.from.email)")
        }
        return errors
    }

    private func isValidEmailFormat(_ email: String) -> Bool {
        let parts = email.split(separator: "@")
        guard parts.count == 2 else { return false }
        guard !parts[0].isEmpty && !parts[1].isEmpty else { return false }
        return parts[1].contains(".")
    }
}

// MARK: - Errors

/// Errors related to Mailer operations.
public enum PrismMailerError: Error, Sendable {
    case missingFrom
    case missingRecipients
    case missingSubject
    case missingBody
    case connectionFailed(String)
    case authenticationFailed(String)
    case sendFailed(String)
    case invalidEmail(String)
}
