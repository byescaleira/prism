import Foundation
import Network
import PrismFoundation

@testable import PrismNetwork

struct NetworkFixtureResponse: PrismEntity, Sendable {
    let id: Int
    let title: String
}

struct NetworkFixturePayload: Codable, Sendable {
    let query: String
}

enum NetworkFixtureBody: Sendable {
    case none
    case payload(NetworkFixturePayload)
    case text(String)

    var value: (any Encodable)? {
        switch self {
        case .none:
            nil
        case .payload(let payload):
            payload
        case .text(let text):
            text
        }
    }
}

struct NetworkFixtureEndpoint: PrismNetworkEndpoint {
    var scheme: PrismNetworkScheme = .https
    var host: String = "example.com"
    var path: String = "/v1/items"
    var method: PrismNetworkMethod = .get
    var queryItems: [URLQueryItem]? = nil
    var headers: [String: String] = [:]
    var requestBody: NetworkFixtureBody = .none
    var timeoutInterval: TimeInterval? = nil
    var cacheInterval: TimeInterval? = nil

    var body: (any Encodable)? {
        requestBody.value
    }
}

struct NetworkFixtureRequest: PrismNetworkRequest {
    typealias Endpoint = NetworkFixtureEndpoint
    typealias Response = NetworkFixtureResponse

    let endpoint: NetworkFixtureEndpoint
}

struct NetworkFixtureSocketCommand: PrismNetworkSocketCommand {
    let message: String
}

struct NetworkFixtureSocketEndpoint: PrismNetworkSocketEndpoint {
    var host: NWEndpoint.Host = "stream.example.com"
    var portValue: UInt16 = 9_000
    var parameters: NWParameters = .tcp

    var port: NWEndpoint.Port {
        get throws {
            guard let port = NWEndpoint.Port(rawValue: portValue) else {
                throw PrismNetworkError.invalidURL
            }

            return port
        }
    }
}

struct NetworkFixtureSocketRequest: PrismNetworkSocketRequest {
    let endpoint: (any PrismNetworkSocketEndpoint)?
}

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    enum Result {
        case response(URLResponse, Data)
        case redirect(HTTPURLResponse, URLRequest)
        case failure(Error)
    }

    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> Result)?
    nonisolated(unsafe) static var requestCount = 0
    nonisolated(unsafe) static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            fatalError("MockURLProtocol.requestHandler was not configured")
        }

        Self.requestCount += 1
        Self.lastRequest = request

        do {
            switch try handler(request) {
            case .response(let response, let data):
                client?.urlProtocol(
                    self,
                    didReceive: response,
                    cacheStoragePolicy: .notAllowed
                )
                if !data.isEmpty {
                    client?.urlProtocol(
                        self,
                        didLoad: data
                    )
                }
                client?.urlProtocolDidFinishLoading(self)

            case .redirect(let response, let newRequest):
                client?.urlProtocol(
                    self,
                    wasRedirectedTo: newRequest,
                    redirectResponse: response
                )

            case .failure(let error):
                client?.urlProtocol(
                    self,
                    didFailWithError: error
                )
            }
        } catch {
            client?.urlProtocol(
                self,
                didFailWithError: error
            )
        }
    }

    override func stopLoading() {}

    static func reset() {
        requestHandler = nil
        requestCount = 0
        lastRequest = nil
    }
}

final class MockSocketConnection: PrismNetworkSocketConnection, @unchecked Sendable {
    var stateUpdateHandler: (@Sendable (PrismNetworkSocketConnectionState) -> Void)?

    var receiveScripts = [(Data?, Bool, Error?)]()
    var sentPayloads = [Data?]()
    var sendError: Error?
    var startCount = 0
    var cancelCount = 0

    func start(queue: DispatchQueue) {
        startCount += 1
    }

    func cancel() {
        cancelCount += 1
        stateUpdateHandler?(.cancelled)
    }

    func receive(
        minimumIncompleteLength: Int,
        maximumLength: Int,
        completion: @escaping @Sendable (Data?, Bool, Error?) -> Void
    ) {
        guard !receiveScripts.isEmpty else {
            completion(
                nil,
                true,
                nil
            )
            return
        }

        let next = receiveScripts.removeFirst()
        completion(
            next.0,
            next.1,
            next.2
        )
    }

    func send(
        content: Data?,
        completion: @escaping @Sendable (Error?) -> Void
    ) {
        sentPayloads.append(content)
        completion(sendError)
    }

    func emit(_ state: PrismNetworkSocketConnectionState) {
        stateUpdateHandler?(state)
    }
}

func makeNetworkAdapter(
    cache: URLCache = URLCache(
        memoryCapacity: 1_024 * 1_024,
        diskCapacity: 1_024 * 1_024
    )
) -> PrismNetworkAdapter {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    configuration.urlCache = cache
    return PrismNetworkAdapter(
        configuration: configuration,
        cache: cache
    )
}

func responseData(
    id: Int = 1,
    title: String = "Prism"
) throws -> Data {
    try JSONEncoder().encode(
        NetworkFixtureResponse(
            id: id,
            title: title
        )
    )
}

func collect(
    from stream: AsyncStream<Data>
) async -> [Data] {
    var values = [Data]()

    for await value in stream {
        values.append(value)
    }

    return values
}

actor SocketServerBox {
    private(set) var receivedData = [Data]()

    func append(_ data: Data) {
        receivedData.append(data)
    }
}
