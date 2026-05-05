import Foundation
import Testing

@testable import PrismServer

@Suite("PrismMailer Tests")
struct PrismMailerTests {

    @Test("Email builder creates email")
    func emailBuilder() throws {
        let email = try PrismEmailBuilder()
            .from("sender@example.com", name: "Sender")
            .to("recipient@example.com")
            .subject("Hello")
            .text("Hello World")
            .build()
        #expect(email.from.email == "sender@example.com")
        #expect(email.to.count == 1)
        #expect(email.subject == "Hello")
        #expect(email.textBody == "Hello World")
    }

    @Test("Builder requires from")
    func builderRequiresFrom() {
        do {
            _ = try PrismEmailBuilder()
                .to("test@example.com")
                .subject("Test")
                .text("Body")
                .build()
            #expect(Bool(false), "Should have thrown")
        } catch PrismMailerError.missingFrom {
            // expected
        } catch {
            #expect(Bool(false), "Wrong error: \(error)")
        }
    }

    @Test("Builder requires recipients")
    func builderRequiresRecipients() {
        do {
            _ = try PrismEmailBuilder()
                .from("test@example.com")
                .subject("Test")
                .text("Body")
                .build()
            #expect(Bool(false), "Should have thrown")
        } catch PrismMailerError.missingRecipients {
            // expected
        } catch {
            #expect(Bool(false), "Wrong error: \(error)")
        }
    }

    @Test("Builder requires subject")
    func builderRequiresSubject() {
        do {
            _ = try PrismEmailBuilder()
                .from("test@example.com")
                .to("recipient@example.com")
                .text("Body")
                .build()
            #expect(Bool(false), "Should have thrown")
        } catch PrismMailerError.missingSubject {
            // expected
        } catch {
            #expect(Bool(false), "Wrong error: \(error)")
        }
    }

    @Test("Builder requires body")
    func builderRequiresBody() {
        do {
            _ = try PrismEmailBuilder()
                .from("test@example.com")
                .to("recipient@example.com")
                .subject("Subject")
                .build()
            #expect(Bool(false), "Should have thrown")
        } catch PrismMailerError.missingBody {
            // expected
        } catch {
            #expect(Bool(false), "Wrong error: \(error)")
        }
    }

    @Test("Email address formatting with name")
    func emailAddressWithName() {
        let addr = PrismEmailAddress("test@example.com", name: "Test User")
        #expect(addr.formatted == "Test User <test@example.com>")
    }

    @Test("Email address formatting without name")
    func emailAddressWithoutName() {
        let addr = PrismEmailAddress("test@example.com")
        #expect(addr.formatted == "test@example.com")
    }

    @Test("MIME builder creates text message")
    func mimeTextMessage() throws {
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .subject("Test")
            .text("Hello World")
            .build()
        let message = PrismMIMEBuilder.buildMessage(email)
        #expect(message.contains("From: sender@example.com"))
        #expect(message.contains("To: recipient@example.com"))
        #expect(message.contains("Subject: Test"))
        #expect(message.contains("text/plain"))
        #expect(message.contains("Hello World"))
    }

    @Test("MIME builder creates HTML message")
    func mimeHTMLMessage() throws {
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .subject("Test")
            .html("<h1>Hello</h1>")
            .build()
        let message = PrismMIMEBuilder.buildMessage(email)
        #expect(message.contains("text/html"))
        #expect(message.contains("<h1>Hello</h1>"))
    }

    @Test("MIME builder multipart alternative")
    func mimeMultipartAlternative() throws {
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .subject("Test")
            .text("Hello")
            .html("<h1>Hello</h1>")
            .build()
        let message = PrismMIMEBuilder.buildMessage(email)
        #expect(message.contains("multipart/alternative"))
        #expect(message.contains("text/plain"))
        #expect(message.contains("text/html"))
    }

    @Test("MIME builder with attachment")
    func mimeWithAttachment() throws {
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .subject("Test")
            .text("See attached")
            .attach(filename: "test.txt", mimeType: "text/plain", data: Data("file content".utf8))
            .build()
        let message = PrismMIMEBuilder.buildMessage(email)
        #expect(message.contains("multipart/mixed"))
        #expect(message.contains("Content-Disposition: attachment"))
        #expect(message.contains("test.txt"))
    }

    @Test("MIME builder includes CC")
    func mimeCCHeader() throws {
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .cc("cc@example.com")
            .subject("Test")
            .text("Body")
            .build()
        let message = PrismMIMEBuilder.buildMessage(email)
        #expect(message.contains("Cc: cc@example.com"))
    }

    @Test("MIME builder includes Reply-To")
    func mimeReplyTo() throws {
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .replyTo("reply@example.com")
            .subject("Test")
            .text("Body")
            .build()
        let message = PrismMIMEBuilder.buildMessage(email)
        #expect(message.contains("Reply-To: reply@example.com"))
    }

    @Test("SMTP commands generated")
    func smtpCommands() async throws {
        let config = PrismSMTPConfig(host: "smtp.example.com", port: 587, username: "user", password: "pass")
        let mailer = PrismMailerService(config: config)
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .subject("Test")
            .text("Body")
            .build()
        let commands = await mailer.buildSMTPCommands(for: email)
        #expect(commands.contains("EHLO smtp.example.com"))
        #expect(commands.contains("MAIL FROM:<sender@example.com>"))
        #expect(commands.contains("RCPT TO:<recipient@example.com>"))
        #expect(commands.contains("QUIT"))
    }

    @Test("SMTP AUTH PLAIN")
    func smtpAuthPlain() async throws {
        let config = PrismSMTPConfig(host: "smtp.example.com", username: "user", password: "pass")
        let mailer = PrismMailerService(config: config, authMethod: .plain)
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .subject("Test")
            .text("Body")
            .build()
        let commands = await mailer.buildSMTPCommands(for: email)
        let authCommand = commands.first(where: { $0.hasPrefix("AUTH PLAIN") })
        #expect(authCommand != nil)
    }

    @Test("Email validation passes valid email")
    func validEmail() async throws {
        let config = PrismSMTPConfig(host: "smtp.example.com")
        let mailer = PrismMailerService(config: config)
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .subject("Test")
            .text("Body")
            .build()
        let errors = await mailer.validateEmail(email)
        #expect(errors.isEmpty)
    }

    @Test("Email validation catches invalid address")
    func invalidEmailAddress() async throws {
        let config = PrismSMTPConfig(host: "smtp.example.com")
        let mailer = PrismMailerService(config: config)
        let email = PrismEmail(
            from: PrismEmailAddress("sender@example.com"),
            to: [PrismEmailAddress("invalid-email")],
            subject: "Test",
            textBody: "Body"
        )
        let errors = await mailer.validateEmail(email)
        #expect(!errors.isEmpty)
    }

    @Test("Builder chaining multiple recipients")
    func multipleRecipients() throws {
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("alice@example.com")
            .to("bob@example.com")
            .bcc("secret@example.com")
            .subject("Group")
            .text("Hello all")
            .build()
        #expect(email.to.count == 2)
        #expect(email.bcc.count == 1)
    }

    @Test("MIME includes Message-ID")
    func mimeMessageId() throws {
        let email = try PrismEmailBuilder()
            .from("sender@example.com")
            .to("recipient@example.com")
            .subject("Test")
            .text("Body")
            .build()
        let message = PrismMIMEBuilder.buildMessage(email)
        #expect(message.contains("Message-ID:"))
    }
}
