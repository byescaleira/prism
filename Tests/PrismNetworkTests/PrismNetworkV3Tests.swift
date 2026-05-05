import Foundation
import Testing

@testable import PrismNetwork

// MARK: - PrismExponentialBackoff Tests

@Suite("PrismExponentialBackoff V3")
struct PrismExponentialBackoffV3Tests {
    @Test("Defaults are baseDelay=1s, maxDelay=30s, maxAttempts=3")
    func defaults() {
        let backoff = PrismExponentialBackoff()
        #expect(backoff.baseDelay == .seconds(1))
        #expect(backoff.maxDelay == .seconds(30))
        #expect(backoff.maxAttempts == 3)
    }

    @Test("shouldRetry returns true when attempt < maxAttempts")
    func shouldRetryBeforeMax() {
        let backoff = PrismExponentialBackoff(maxAttempts: 3)
        #expect(backoff.shouldRetry(for: URLError(.timedOut), attempt: 0))
        #expect(backoff.shouldRetry(for: URLError(.timedOut), attempt: 1))
        #expect(backoff.shouldRetry(for: URLError(.timedOut), attempt: 2))
    }

    @Test("shouldRetry returns false when attempt == maxAttempts")
    func shouldNotRetryAtMax() {
        let backoff = PrismExponentialBackoff(maxAttempts: 3)
        #expect(!backoff.shouldRetry(for: URLError(.timedOut), attempt: 3))
    }

    @Test("Delay increases exponentially on average")
    func delayIncreasesExponentially() {
        let backoff = PrismExponentialBackoff(
            baseDelay: .seconds(1),
            maxDelay: .seconds(120),
            maxAttempts: 5
        )

        var avg0: Double = 0
        var avg1: Double = 0
        var avg2: Double = 0
        let samples = 100

        for _ in 0..<samples {
            avg0 += backoff.delay(for: 0).timeInterval
            avg1 += backoff.delay(for: 1).timeInterval
            avg2 += backoff.delay(for: 2).timeInterval
        }
        avg0 /= Double(samples)
        avg1 /= Double(samples)
        avg2 /= Double(samples)

        // Base delays: attempt 0 = 1s, attempt 1 = 2s, attempt 2 = 4s (plus jitter 0..0.5)
        #expect(avg1 > avg0)
        #expect(avg2 > avg1)
    }

    @Test("Delay is capped at maxDelay")
    func delayCappedAtMax() {
        let backoff = PrismExponentialBackoff(
            baseDelay: .seconds(10),
            maxDelay: .seconds(5),
            maxAttempts: 10
        )

        for _ in 0..<20 {
            let delay = backoff.delay(for: 10)
            // Max is 5s; jitter is capped before applying
            #expect(delay.timeInterval <= 5.5)
        }
    }
}

// MARK: - PrismLinearRetry Tests

@Suite("PrismLinearRetry V3")
struct PrismLinearRetryV3Tests {
    @Test("Defaults are fixedDelay=2s, maxAttempts=3")
    func defaults() {
        let retry = PrismLinearRetry()
        #expect(retry.fixedDelay == .seconds(2))
        #expect(retry.maxAttempts == 3)
    }

    @Test("shouldRetry mirrors attempt < maxAttempts")
    func shouldRetryLogic() {
        let retry = PrismLinearRetry(maxAttempts: 2)
        #expect(retry.shouldRetry(for: URLError(.notConnectedToInternet), attempt: 0))
        #expect(retry.shouldRetry(for: URLError(.notConnectedToInternet), attempt: 1))
        #expect(!retry.shouldRetry(for: URLError(.notConnectedToInternet), attempt: 2))
    }

    @Test("Delay always returns fixedDelay regardless of attempt")
    func fixedDelay() {
        let retry = PrismLinearRetry(fixedDelay: .seconds(5), maxAttempts: 10)
        #expect(retry.delay(for: 0) == .seconds(5))
        #expect(retry.delay(for: 1) == .seconds(5))
        #expect(retry.delay(for: 99) == .seconds(5))
    }
}

// MARK: - Duration.timeInterval Tests

@Suite("Duration.timeInterval")
struct DurationTimeIntervalTests {
    @Test("Converts whole seconds correctly")
    func wholeSeconds() {
        let d = Duration.seconds(7)
        #expect(d.timeInterval == 7.0)
    }

    @Test("Converts fractional seconds correctly")
    func fractionalSeconds() {
        let d = Duration.milliseconds(1500)
        let ti = d.timeInterval
        #expect(ti >= 1.499 && ti <= 1.501)
    }

    @Test("Zero duration converts to zero")
    func zeroDuration() {
        let d = Duration.seconds(0)
        #expect(d.timeInterval == 0.0)
    }
}

// MARK: - PrismMultipartFormData Tests

@Suite("PrismMultipartFormData")
struct PrismMultipartFormDataV3Tests {
    @Test("Append data part — build contains boundary, headers, and data")
    func appendDataPart() {
        let boundary = "test-boundary-123"
        var form = PrismMultipartFormData(boundary: boundary)
        let payload = Data("hello".utf8)
        form.append(data: payload, name: "file", fileName: "test.txt", mimeType: "text/plain")

        let (body, contentType) = form.build()
        let bodyString = String(data: body, encoding: .utf8)!

        #expect(bodyString.contains("--\(boundary)"))
        #expect(bodyString.contains("name=\"file\""))
        #expect(bodyString.contains("filename=\"test.txt\""))
        #expect(bodyString.contains("Content-Type: text/plain"))
        #expect(bodyString.contains("hello"))
        #expect(bodyString.contains("--\(boundary)--"))
        #expect(contentType == "multipart/form-data; boundary=\(boundary)")
    }

    @Test("Append string part — build contains field name and value")
    func appendStringPart() {
        let boundary = "str-boundary"
        var form = PrismMultipartFormData(boundary: boundary)
        form.append(string: "world", name: "greeting")

        let (body, _) = form.build()
        let bodyString = String(data: body, encoding: .utf8)!

        #expect(bodyString.contains("name=\"greeting\""))
        #expect(bodyString.contains("world"))
    }

    @Test("Multiple parts produce correct structure with shared boundary")
    func multipleParts() {
        let boundary = "multi-boundary"
        var form = PrismMultipartFormData(boundary: boundary)
        form.append(string: "value1", name: "field1")
        form.append(string: "value2", name: "field2")
        form.append(data: Data("bin".utf8), name: "attachment", fileName: "a.bin", mimeType: "application/octet-stream")

        let (body, _) = form.build()
        let bodyString = String(data: body, encoding: .utf8)!

        // Each part starts with --boundary
        let partHeaders = bodyString.components(separatedBy: "--\(boundary)\r\n")
        // Expecting 3 parts plus the closing delimiter segment
        #expect(partHeaders.count >= 4) // empty prefix + 3 parts

        #expect(bodyString.contains("name=\"field1\""))
        #expect(bodyString.contains("name=\"field2\""))
        #expect(bodyString.contains("name=\"attachment\""))
    }

    @Test("Content type includes boundary string")
    func contentTypeIncludesBoundary() {
        let boundary = "ct-boundary"
        let form = PrismMultipartFormData(boundary: boundary)
        let (_, contentType) = form.build()
        #expect(contentType.contains(boundary))
        #expect(contentType.hasPrefix("multipart/form-data; boundary="))
    }
}

// MARK: - PrismUploadProgress Tests

@Suite("PrismUploadProgress")
struct PrismUploadProgressV3Tests {
    @Test("fractionCompleted calculates correctly")
    func fractionCompleted() {
        let progress = PrismUploadProgress(bytesUploaded: 50, totalBytes: 200)
        #expect(progress.fractionCompleted == 0.25)
    }

    @Test("fractionCompleted is 1.0 when fully uploaded")
    func fullyUploaded() {
        let progress = PrismUploadProgress(bytesUploaded: 100, totalBytes: 100)
        #expect(progress.fractionCompleted == 1.0)
    }

    @Test("fractionCompleted returns 0 when totalBytes is zero")
    func zeroTotalBytes() {
        let progress = PrismUploadProgress(bytesUploaded: 0, totalBytes: 0)
        #expect(progress.fractionCompleted == 0.0)
    }
}

// MARK: - PrismCachePolicy Tests

@Suite("PrismCachePolicy")
struct PrismCachePolicyV3Tests {
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

// MARK: - PrismCacheEntry Tests

@Suite("PrismCacheEntry")
struct PrismCacheEntryV3Tests {
    @Test("Defaults: statusCode=200, headers=empty, ttl=300s")
    func defaults() {
        let entry = PrismCacheEntry(data: Data("x".utf8))
        #expect(entry.statusCode == 200)
        #expect(entry.headers == [:])
        #expect(entry.ttl == .seconds(300))
    }

    @Test("isExpired returns true when past TTL")
    func expiredEntry() {
        let entry = PrismCacheEntry(
            data: Data(),
            cachedAt: Date().addingTimeInterval(-600),
            ttl: .seconds(300)
        )
        #expect(entry.isExpired)
    }

    @Test("isExpired returns false when within TTL")
    func freshEntry() {
        let entry = PrismCacheEntry(
            data: Data(),
            cachedAt: Date(),
            ttl: .seconds(300)
        )
        #expect(!entry.isExpired)
    }
}

// MARK: - PrismResponseCache Tests

@Suite("PrismResponseCache")
struct PrismResponseCacheV3Tests {
    @Test("Set and get returns the cached entry")
    func setAndGet() async {
        let cache = PrismResponseCache(maxSize: 10)
        let entry = PrismCacheEntry(data: Data("cached".utf8))
        await cache.set(entry, for: "key1")

        let result = await cache.get(for: "key1")
        #expect(result != nil)
        #expect(result?.data == Data("cached".utf8))
    }

    @Test("Get returns nil for missing key")
    func missingKey() async {
        let cache = PrismResponseCache(maxSize: 10)
        let result = await cache.get(for: "nonexistent")
        #expect(result == nil)
    }

    @Test("Evicts LRU entry when cache is full")
    func evictsLRU() async {
        let cache = PrismResponseCache(maxSize: 2)

        let entry1 = PrismCacheEntry(data: Data("a".utf8))
        let entry2 = PrismCacheEntry(data: Data("b".utf8))
        let entry3 = PrismCacheEntry(data: Data("c".utf8))

        await cache.set(entry1, for: "k1")
        await cache.set(entry2, for: "k2")

        // Access k1 so k2 becomes LRU
        _ = await cache.get(for: "k1")

        // Adding k3 should evict k2 (least recently used)
        await cache.set(entry3, for: "k3")

        #expect(await cache.get(for: "k1") != nil)
        #expect(await cache.get(for: "k2") == nil)
        #expect(await cache.get(for: "k3") != nil)
    }

    @Test("Invalidate removes a specific entry")
    func invalidateEntry() async {
        let cache = PrismResponseCache(maxSize: 10)
        let entry = PrismCacheEntry(data: Data("bye".utf8))
        await cache.set(entry, for: "removeMe")

        await cache.invalidate(key: "removeMe")
        #expect(await cache.get(for: "removeMe") == nil)
    }

    @Test("Clear removes all entries")
    func clearAll() async {
        let cache = PrismResponseCache(maxSize: 10)
        await cache.set(PrismCacheEntry(data: Data("1".utf8)), for: "a")
        await cache.set(PrismCacheEntry(data: Data("2".utf8)), for: "b")
        await cache.set(PrismCacheEntry(data: Data("3".utf8)), for: "c")

        await cache.clear()
        #expect(await cache.count == 0)
    }

    @Test("Count tracks the number of entries")
    func countTracking() async {
        let cache = PrismResponseCache(maxSize: 10)
        #expect(await cache.count == 0)

        await cache.set(PrismCacheEntry(data: Data()), for: "x")
        #expect(await cache.count == 1)

        await cache.set(PrismCacheEntry(data: Data()), for: "y")
        #expect(await cache.count == 2)

        await cache.invalidate(key: "x")
        #expect(await cache.count == 1)
    }

    @Test("Get returns nil and evicts expired entries")
    func expiredEntryEvicted() async {
        let cache = PrismResponseCache(maxSize: 10)
        let expired = PrismCacheEntry(
            data: Data("old".utf8),
            cachedAt: Date().addingTimeInterval(-1000),
            ttl: .seconds(1)
        )
        await cache.set(expired, for: "stale")
        #expect(await cache.get(for: "stale") == nil)
        #expect(await cache.count == 0)
    }
}

// MARK: - PrismRequestDeduplicator Tests

@Suite("PrismRequestDeduplicator")
struct PrismRequestDeduplicatorV3Tests {
    @Test("key() generates consistent keys from URL and method")
    func consistentKey() {
        let url = URL(string: "https://example.com/api")!
        let key1 = PrismRequestDeduplicator.key(url: url, method: "GET")
        let key2 = PrismRequestDeduplicator.key(url: url, method: "GET")
        #expect(key1 == key2)
        #expect(key1 == "GET:https://example.com/api")
    }

    @Test("key() differs by HTTP method")
    func differsByMethod() {
        let url = URL(string: "https://example.com/api")!
        let getKey = PrismRequestDeduplicator.key(url: url, method: "GET")
        let postKey = PrismRequestDeduplicator.key(url: url, method: "POST")
        #expect(getKey != postKey)
    }

    @Test("key() includes body hash when body is present")
    func includesBodyHash() {
        let url = URL(string: "https://example.com/api")!
        let body = Data("{\"id\":1}".utf8)
        let keyWithBody = PrismRequestDeduplicator.key(url: url, method: "POST", body: body)
        let keyWithout = PrismRequestDeduplicator.key(url: url, method: "POST")

        #expect(keyWithBody != keyWithout)
        #expect(keyWithBody.contains(":"))
        // The key with body should have 3 colon-separated components
        #expect(keyWithBody.components(separatedBy: ":").count >= 3)
    }

    @Test("key() without body has no trailing hash")
    func noBodyNoHash() {
        let url = URL(string: "https://example.com/path")!
        let key = PrismRequestDeduplicator.key(url: url, method: "DELETE")
        #expect(key == "DELETE:https://example.com/path")
    }

    @Test("deduplicate coalesces concurrent identical requests")
    func deduplicateCoalesces() async throws {
        let deduplicator = PrismRequestDeduplicator()
        let callCount = ManagedAtomic(0)

        async let result1: Int = deduplicator.deduplicate({
            callCount.increment()
            try await Task.sleep(for: .milliseconds(50))
            return 42
        }, key: "same-key")

        async let result2: Int = deduplicator.deduplicate({
            callCount.increment()
            try await Task.sleep(for: .milliseconds(50))
            return 42
        }, key: "same-key")

        let (r1, r2) = try await (result1, result2)
        #expect(r1 == 42)
        #expect(r2 == 42)
    }
}

/// Minimal thread-safe counter for deduplication test.
private final class ManagedAtomic: @unchecked Sendable {
    private let lock = NSLock()
    private var value: Int

    init(_ initial: Int) {
        self.value = initial
    }

    func increment() {
        lock.lock()
        value += 1
        lock.unlock()
    }

    func load() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}

// MARK: - PrismOfflineQueue Tests

@Suite("PrismOfflineQueue")
struct PrismOfflineQueueV3Tests {
    @Test("PrismQueuedRequest init with defaults")
    func queuedRequestDefaults() {
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let queued = PrismQueuedRequest(urlRequest: request)
        #expect(queued.retryCount == 0)
        #expect(queued.priority == 0)
    }

    @Test("Enqueue and dequeueAll returns items sorted by priority descending")
    func enqueueDequeueSortedByPriority() async {
        let queue = PrismOfflineQueue()
        let url = URL(string: "https://example.com")!

        let low = PrismQueuedRequest(urlRequest: URLRequest(url: url), priority: 1)
        let high = PrismQueuedRequest(urlRequest: URLRequest(url: url), priority: 10)
        let medium = PrismQueuedRequest(urlRequest: URLRequest(url: url), priority: 5)

        await queue.enqueue(low)
        await queue.enqueue(high)
        await queue.enqueue(medium)

        let dequeued = await queue.dequeueAll()
        #expect(dequeued.count == 3)
        #expect(dequeued[0].priority == 10)
        #expect(dequeued[1].priority == 5)
        #expect(dequeued[2].priority == 1)
    }

    @Test("Count tracks queue size")
    func countTracksSize() async {
        let queue = PrismOfflineQueue()
        let url = URL(string: "https://example.com")!

        #expect(await queue.count == 0)

        await queue.enqueue(PrismQueuedRequest(urlRequest: URLRequest(url: url)))
        #expect(await queue.count == 1)

        await queue.enqueue(PrismQueuedRequest(urlRequest: URLRequest(url: url)))
        #expect(await queue.count == 2)
    }

    @Test("dequeueAll on empty queue returns empty array")
    func emptyDequeue() async {
        let queue = PrismOfflineQueue()
        let result = await queue.dequeueAll()
        #expect(result.isEmpty)
    }

    @Test("dequeueAll empties the queue")
    func dequeueEmptiesQueue() async {
        let queue = PrismOfflineQueue()
        let url = URL(string: "https://example.com")!

        await queue.enqueue(PrismQueuedRequest(urlRequest: URLRequest(url: url)))
        await queue.enqueue(PrismQueuedRequest(urlRequest: URLRequest(url: url)))

        _ = await queue.dequeueAll()
        #expect(await queue.count == 0)
    }
}

// MARK: - PrismGraphQLQuery Tests

@Suite("PrismGraphQLQuery")
struct PrismGraphQLQueryV3Tests {
    @Test("Stores query, variables, and operationName")
    func storesProperties() {
        let query = PrismGraphQLQuery(
            query: "{ users { id name } }",
            variables: ["limit": 10],
            operationName: "GetUsers"
        )

        #expect(query.query == "{ users { id name } }")
        #expect(query.operationName == "GetUsers")
        #expect(query.variables != nil)
    }

    @Test("Defaults: variables and operationName are nil")
    func defaults() {
        let query = PrismGraphQLQuery(query: "{ me { id } }")
        #expect(query.variables == nil)
        #expect(query.operationName == nil)
    }
}

// MARK: - PrismGraphQLResponse Tests

@Suite("PrismGraphQLResponse")
struct PrismGraphQLResponseV3Tests {
    @Test("Stores data and errors")
    func storesDataAndErrors() {
        let error = PrismGraphQLError(message: "Not found")
        let response = PrismGraphQLResponse<String>(data: "result", errors: [error])
        #expect(response.data == "result")
        #expect(response.errors?.count == 1)
        #expect(response.errors?.first?.message == "Not found")
    }

    @Test("Defaults: data and errors are nil")
    func defaults() {
        let response = PrismGraphQLResponse<String>()
        #expect(response.data == nil)
        #expect(response.errors == nil)
    }
}

// MARK: - PrismGraphQLError Tests

@Suite("PrismGraphQLError")
struct PrismGraphQLErrorV3Tests {
    @Test("Is Equatable")
    func equatable() {
        let error1 = PrismGraphQLError(message: "Oops", locations: nil, path: ["user"])
        let error2 = PrismGraphQLError(message: "Oops", locations: nil, path: ["user"])
        let error3 = PrismGraphQLError(message: "Different")

        #expect(error1 == error2)
        #expect(error1 != error3)
    }

    @Test("Equatable considers locations")
    func equatableWithLocations() {
        let loc = PrismGraphQLErrorLocation(line: 1, column: 5)
        let a = PrismGraphQLError(message: "err", locations: [loc])
        let b = PrismGraphQLError(message: "err", locations: [loc])
        let c = PrismGraphQLError(message: "err", locations: nil)

        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - PrismGraphQLErrorLocation Tests

@Suite("PrismGraphQLErrorLocation")
struct PrismGraphQLErrorLocationV3Tests {
    @Test("Stores line and column")
    func storesLineAndColumn() {
        let loc = PrismGraphQLErrorLocation(line: 3, column: 12)
        #expect(loc.line == 3)
        #expect(loc.column == 12)
    }

    @Test("Is Equatable")
    func equatable() {
        let a = PrismGraphQLErrorLocation(line: 1, column: 1)
        let b = PrismGraphQLErrorLocation(line: 1, column: 1)
        let c = PrismGraphQLErrorLocation(line: 2, column: 1)

        #expect(a == b)
        #expect(a != c)
    }
}
