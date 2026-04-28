import Foundation
import Testing

@testable import PrismNetwork

// MARK: - Retry Policy Tests

@Suite("PrismExponentialBackoff")
struct PrismExponentialBackoffTests {
    @Test("Delay increases with each attempt")
    func delayIncreases() {
        let backoff = PrismExponentialBackoff(
            baseDelay: .seconds(1),
            maxDelay: .seconds(60),
            maxAttempts: 5
        )

        // Collect multiple samples to account for jitter
        var attempt0Total: Double = 0
        var attempt2Total: Double = 0
        let samples = 50

        for _ in 0..<samples {
            let delay0 = backoff.delay(for: 0)
            let delay2 = backoff.delay(for: 2)
            attempt0Total += delay0.timeInterval
            attempt2Total += delay2.timeInterval
        }

        let avgDelay0 = attempt0Total / Double(samples)
        let avgDelay2 = attempt2Total / Double(samples)

        // Attempt 2 base is 4s vs attempt 0 base of 1s, so average should be higher
        #expect(avgDelay2 > avgDelay0)
    }

    @Test("Respects max attempts")
    func respectsMaxAttempts() {
        let backoff = PrismExponentialBackoff(maxAttempts: 3)

        #expect(backoff.shouldRetry(for: URLError(.timedOut), attempt: 0) == true)
        #expect(backoff.shouldRetry(for: URLError(.timedOut), attempt: 1) == true)
        #expect(backoff.shouldRetry(for: URLError(.timedOut), attempt: 2) == true)
        #expect(backoff.shouldRetry(for: URLError(.timedOut), attempt: 3) == false)
    }

    @Test("Delay is capped by maxDelay")
    func delayCapped() {
        let backoff = PrismExponentialBackoff(
            baseDelay: .seconds(10),
            maxDelay: .seconds(5),
            maxAttempts: 10
        )

        let delay = backoff.delay(for: 5)
        #expect(delay.timeInterval <= 5.5) // 5s max + up to 0.5s jitter
    }
}

// MARK: - Linear Retry Tests

@Suite("PrismLinearRetry")
struct PrismLinearRetryTests {
    @Test("Returns constant delay")
    func constantDelay() {
        let retry = PrismLinearRetry(fixedDelay: .seconds(3), maxAttempts: 5)

        let delay0 = retry.delay(for: 0)
        let delay1 = retry.delay(for: 1)
        let delay4 = retry.delay(for: 4)

        #expect(delay0 == delay1)
        #expect(delay1 == delay4)
        #expect(delay0 == .seconds(3))
    }

    @Test("Respects max attempts")
    func respectsMaxAttempts() {
        let retry = PrismLinearRetry(fixedDelay: .seconds(1), maxAttempts: 2)

        #expect(retry.shouldRetry(for: URLError(.timedOut), attempt: 0) == true)
        #expect(retry.shouldRetry(for: URLError(.timedOut), attempt: 1) == true)
        #expect(retry.shouldRetry(for: URLError(.timedOut), attempt: 2) == false)
    }
}

// MARK: - Retryable Request Tests

@Suite("PrismRetryableRequest")
struct PrismRetryableRequestTests {
    @Test("Succeeds on first attempt without retry")
    func succeedsImmediately() async throws {
        let request = PrismRetryableRequest(
            policy: PrismLinearRetry(fixedDelay: .milliseconds(1), maxAttempts: 3)
        ) {
            42
        }
        let result = try await request.execute()
        #expect(result == 42)
    }
}

// MARK: - Request Deduplicator Tests

@Suite("PrismRequestDeduplicator")
struct PrismRequestDeduplicatorTests {
    @Test("Returns same result for same key")
    func sameKeySharesResult() async throws {
        let deduplicator = PrismRequestDeduplicator()

        let callCount = MutableBox(0)
        let key = "test-key"

        async let result1: Int = deduplicator.deduplicate({
            await callCount.increment()
            try await Task.sleep(for: .milliseconds(50))
            return 99
        }, key: key)

        async let result2: Int = deduplicator.deduplicate({
            await callCount.increment()
            try await Task.sleep(for: .milliseconds(50))
            return 99
        }, key: key)

        let r1 = try await result1
        let r2 = try await result2

        #expect(r1 == 99)
        #expect(r2 == 99)
    }

    @Test("Key generation includes URL and method")
    func keyGeneration() {
        let url = URL(string: "https://api.example.com/data")!
        let key = PrismRequestDeduplicator.key(url: url, method: "GET")
        #expect(key.contains("GET"))
        #expect(key.contains("https://api.example.com/data"))
    }
}

// MARK: - Offline Queue Tests

@Suite("PrismOfflineQueue")
struct PrismOfflineQueueTests {
    @Test("Stores queued request properties")
    func queuedRequestProperties() {
        let urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        let queued = PrismQueuedRequest(
            urlRequest: urlRequest,
            retryCount: 2,
            priority: 5
        )

        #expect(queued.retryCount == 2)
        #expect(queued.priority == 5)
        #expect(queued.urlRequest.url?.absoluteString == "https://example.com")
    }

    @Test("Enqueue and dequeue")
    func enqueueDequeue() async {
        let queue = PrismOfflineQueue()
        let request1 = PrismQueuedRequest(
            urlRequest: URLRequest(url: URL(string: "https://a.com")!),
            priority: 1
        )
        let request2 = PrismQueuedRequest(
            urlRequest: URLRequest(url: URL(string: "https://b.com")!),
            priority: 10
        )

        await queue.enqueue(request1)
        await queue.enqueue(request2)

        let dequeued = await queue.dequeueAll()
        #expect(dequeued.count == 2)
        // Higher priority first
        #expect(dequeued[0].priority == 10)
        #expect(dequeued[1].priority == 1)
    }

    @Test("Count reflects enqueued items")
    func count() async {
        let queue = PrismOfflineQueue()
        #expect(await queue.count == 0)

        await queue.enqueue(
            PrismQueuedRequest(urlRequest: URLRequest(url: URL(string: "https://a.com")!))
        )
        #expect(await queue.count == 1)

        await queue.enqueue(
            PrismQueuedRequest(urlRequest: URLRequest(url: URL(string: "https://b.com")!))
        )
        #expect(await queue.count == 2)

        _ = await queue.dequeueAll()
        #expect(await queue.count == 0)
    }
}

// MARK: - Cache Policy Tests

@Suite("PrismCachePolicy")
struct PrismCachePolicyTests {
    @Test("Has exactly 4 cases")
    func fourCases() {
        let allCases = PrismCachePolicy.allCases
        #expect(allCases.count == 4)
        #expect(allCases.contains(.networkOnly))
        #expect(allCases.contains(.cacheFirst))
        #expect(allCases.contains(.cacheThenNetwork))
        #expect(allCases.contains(.staleWhileRevalidate))
    }
}

// MARK: - Cache Entry Tests

@Suite("PrismCacheEntry")
struct PrismCacheEntryTests {
    @Test("Respects TTL — non-expired entry")
    func respectsTTLNotExpired() {
        let entry = PrismCacheEntry(
            data: Data("test".utf8),
            cachedAt: Date(),
            ttl: .seconds(300)
        )
        #expect(entry.isExpired == false)
    }

    @Test("Respects TTL — expired entry")
    func respectsTTLExpired() {
        let entry = PrismCacheEntry(
            data: Data("test".utf8),
            cachedAt: Date(timeIntervalSinceNow: -600),
            ttl: .seconds(300)
        )
        #expect(entry.isExpired == true)
    }
}

// MARK: - Response Cache Tests

@Suite("PrismResponseCache")
struct PrismResponseCacheTests {
    @Test("Set and get roundtrip")
    func setGetRoundtrip() async {
        let cache = PrismResponseCache(maxSize: 10)
        let entry = PrismCacheEntry(
            data: Data("hello".utf8),
            statusCode: 200,
            ttl: .seconds(300)
        )

        await cache.set(entry, for: "key1")
        let retrieved = await cache.get(for: "key1")

        #expect(retrieved != nil)
        #expect(retrieved?.data == Data("hello".utf8))
        #expect(retrieved?.statusCode == 200)
    }

    @Test("Invalidate removes entry")
    func invalidateRemoves() async {
        let cache = PrismResponseCache(maxSize: 10)
        let entry = PrismCacheEntry(
            data: Data("data".utf8),
            ttl: .seconds(300)
        )

        await cache.set(entry, for: "key1")
        #expect(await cache.get(for: "key1") != nil)

        await cache.invalidate(key: "key1")
        #expect(await cache.get(for: "key1") == nil)
    }

    @Test("Expired entries return nil on get")
    func expiredReturnsNil() async {
        let cache = PrismResponseCache(maxSize: 10)
        let entry = PrismCacheEntry(
            data: Data("stale".utf8),
            cachedAt: Date(timeIntervalSinceNow: -600),
            ttl: .seconds(60)
        )

        await cache.set(entry, for: "expired-key")
        let retrieved = await cache.get(for: "expired-key")
        #expect(retrieved == nil)
    }

    @Test("LRU eviction when at capacity")
    func lruEviction() async {
        let cache = PrismResponseCache(maxSize: 2)

        await cache.set(
            PrismCacheEntry(data: Data("a".utf8), ttl: .seconds(300)),
            for: "key-a"
        )
        await cache.set(
            PrismCacheEntry(data: Data("b".utf8), ttl: .seconds(300)),
            for: "key-b"
        )
        // Access key-a to make key-b the LRU
        _ = await cache.get(for: "key-a")
        // Adding key-c should evict key-b
        await cache.set(
            PrismCacheEntry(data: Data("c".utf8), ttl: .seconds(300)),
            for: "key-c"
        )

        #expect(await cache.get(for: "key-a") != nil)
        #expect(await cache.get(for: "key-b") == nil)
        #expect(await cache.get(for: "key-c") != nil)
    }
}

// MARK: - GraphQL Tests

@Suite("PrismGraphQL")
struct PrismGraphQLTests {
    @Test("Query stores query and variables")
    func queryStoresProperties() {
        let query = PrismGraphQLQuery(
            query: "{ user(id: 1) { name } }",
            variables: ["id": 1],
            operationName: "GetUser"
        )

        #expect(query.query == "{ user(id: 1) { name } }")
        #expect(query.operationName == "GetUser")
        #expect(query.variables != nil)
    }

    @Test("Error stores message")
    func errorStoresMessage() {
        let error = PrismGraphQLError(
            message: "Field not found",
            locations: [PrismGraphQLErrorLocation(line: 1, column: 5)],
            path: ["user", "name"]
        )

        #expect(error.message == "Field not found")
        #expect(error.locations?.count == 1)
        #expect(error.path?.count == 2)
    }

    @Test("Response holds data and errors")
    func responseHoldsDataAndErrors() {
        let response = PrismGraphQLResponse<String>(
            data: "result",
            errors: [PrismGraphQLError(message: "warning")]
        )

        #expect(response.data == "result")
        #expect(response.errors?.count == 1)
    }
}

// MARK: - Multipart Upload Tests

@Suite("PrismMultipartFormData")
struct PrismMultipartFormDataTests {
    @Test("Builds non-empty data")
    func buildsNonEmpty() {
        var formData = PrismMultipartFormData()
        formData.append(
            data: Data("file-content".utf8),
            name: "file",
            fileName: "test.txt",
            mimeType: "text/plain"
        )

        let (body, contentType) = formData.build()
        #expect(!body.isEmpty)
        #expect(contentType.contains("multipart/form-data"))
        #expect(contentType.contains("boundary="))
    }

    @Test("Append string field")
    func appendString() {
        var formData = PrismMultipartFormData()
        formData.append(string: "hello", name: "greeting")

        let (body, _) = formData.build()
        let bodyString = String(data: body, encoding: .utf8) ?? ""
        #expect(bodyString.contains("hello"))
        #expect(bodyString.contains("greeting"))
    }

    @Test("Multiple parts produce valid body")
    func multipleParts() {
        var formData = PrismMultipartFormData()
        formData.append(string: "value1", name: "field1")
        formData.append(string: "value2", name: "field2")
        formData.append(
            data: Data("binary".utf8),
            name: "attachment",
            fileName: "doc.pdf",
            mimeType: "application/pdf"
        )

        let (body, _) = formData.build()
        let bodyString = String(data: body, encoding: .utf8) ?? ""
        #expect(bodyString.contains("field1"))
        #expect(bodyString.contains("field2"))
        #expect(bodyString.contains("doc.pdf"))
    }
}

// MARK: - Upload Progress Tests

@Suite("PrismUploadProgress")
struct PrismUploadProgressTests {
    @Test("Fraction calculation")
    func fractionCalculation() {
        let progress = PrismUploadProgress(bytesUploaded: 50, totalBytes: 100)
        #expect(progress.fractionCompleted == 0.5)
    }

    @Test("Fraction is zero when total is zero")
    func fractionZeroTotal() {
        let progress = PrismUploadProgress(bytesUploaded: 0, totalBytes: 0)
        #expect(progress.fractionCompleted == 0.0)
    }

    @Test("Complete upload has fraction 1.0")
    func fractionComplete() {
        let progress = PrismUploadProgress(bytesUploaded: 200, totalBytes: 200)
        #expect(progress.fractionCompleted == 1.0)
    }
}

// MARK: - Test Helpers

/// Thread-safe mutable counter for testing.
private actor MutableBox {
    var value: Int

    init(_ value: Int) {
        self.value = value
    }

    func increment() {
        value += 1
    }
}
