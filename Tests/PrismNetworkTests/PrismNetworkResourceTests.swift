import Foundation
import SwiftUI
import Testing

@testable import PrismNetwork

struct PrismNetworkResourceTests {
    @Test
    func enumsExposeStableRawValues() {
        #expect(PrismNetworkMethod.get.rawValue == "GET")
        #expect(PrismNetworkScheme.wss.rawValue == "wss")
        #expect(PrismNetworkHeaderType.json.rawValue == "application/json")
        #expect(PrismNetworkMethod.allCases.count == 5)
        #expect(PrismNetworkScheme.allCases.count == 4)
    }

    @Test
    func errorsAndMappingHelpersReturnExpectedValues() {
        let errors: [PrismNetworkError] = [
            .invalidURL,
            .invalidResponse,
            .noConnectivity,
            .badRequest,
            .serverError,
            .unauthorized,
            .forbidden,
            .noCache,
        ]

        for error in errors {
            #expect(error.description.isEmpty == false)
            #expect(error.errorDescription?.isEmpty == false)
            #expect(error.failureReason?.isEmpty == false)
            #expect(error.recoverySuggestion?.isEmpty == false)
            error.log()
        }

        #expect(PrismNetworkError.from(statusCode: 400) == .badRequest)
        #expect(PrismNetworkError.from(statusCode: 403) == .forbidden)
        #expect(PrismNetworkError.from(statusCode: 503) == .serverError)
        #expect(PrismNetworkError.from(statusCode: 418) == .invalidResponse)
        #expect(PrismNetworkError.from(error: PrismNetworkError.noCache) == .noCache)
        #expect(PrismNetworkError.from(error: URLError(.badURL)) == .invalidURL)
        #expect(PrismNetworkError.from(error: URLError(.timedOut)) == .noConnectivity)
        #expect(PrismNetworkError.from(error: URLError(.cancelled)) == .invalidResponse)
        #expect(
            PrismNetworkError.from(
                error: NSError(
                    domain: "tests",
                    code: 1
                )
            ) == .invalidResponse
        )
    }

    @Test
    func logMessagesStringsAndLoggerRemainUsable() {
        let logger = PrismNetworkLogger()
        let url = URL(string: "https://example.com")!
        let messages: [PrismNetworkLogMessage] = [
            .url(url),
            .headers(["Accept": "application/json"]),
            .body("{\"key\":true}"),
            .host("example.com"),
            .port(443),
            .parameters("tcp"),
            .requestStart(url.absoluteString),
            .cacheHit(url.absoluteString),
            .cacheMiss(url.absoluteString, "forced"),
            .responseCached(url.absoluteString),
            .noCache(url.absoluteString),
            .cacheWithExpiration(url.absoluteString, 42),
            .noCacheInterval(url.absoluteString),
            .cacheStored(url.absoluteString, 84),
            .invalidURL("bad"),
            .connecting("example.com", "443", "tcp"),
            .connectionEstablished("example.com", "443"),
            .connectionClosed("example.com", "443"),
            .disconnected("example.com", "443"),
            .connectionReady,
            .connectionCancelled,
            .connectionFailed("forced"),
            .connectionStateChanged("waiting"),
            .receiveError("forced"),
            .receptionComplete,
            .failedToEncode("message"),
            .sendingMessage("PING"),
            .messageSent("PONG"),
            .sendError("forced"),
        ]
        let localized = String.localized(for: .invalidURLDescription)

        for message in messages {
            #expect(message.key.isEmpty == false)
            #expect(message.format.isEmpty == false)
            #expect(message.value.isEmpty == false)
        }

        #expect(localized.isEmpty == false)
        #expect(String.localized(for: .cacheInvertvalKey).isEmpty == false)
        #expect(
            String.localized(
                for: .invalidURLDescription,
                with: "ignored"
            ).isEmpty == false
        )
        #expect(PrismNetworkString.invalidURLDescription.localized == LocalizedStringKey("invalidURLDescription"))

        logger.info(.url(url))
        logger.warning(.noCache(url.absoluteString))
        logger.error(.connectionFailed("forced"))
        logger.info("plain")
        logger.warning("plain")
        logger.error("plain")
    }
}
