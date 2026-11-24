import Foundation
import Networking
import os

final class StubURLProtocol: URLProtocol {
    enum Stub: Sendable {
        case response(statusCode: Int, data: Data)
        case nonHTTPResponse
        case failure(URLError.Code)
    }

    private static let stubs = OSAllocatedUnfairLock<[URL: Stub]>(initialState: [:])

    static func client(stubbing stub: Stub) -> (URLSessionHTTPClient, URLRequest) {
        let url = URL(string: "https://stub.test/\(UUID().uuidString)")!
        stubs.withLock { $0[url] = stub }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let client = URLSessionHTTPClient(session: URLSession(configuration: configuration))
        return (client, URLRequest(url: url))
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url, let stub = Self.stubs.withLock({ $0[url] }) else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }
        switch stub {
        case let .response(statusCode, data):
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        case .nonHTTPResponse:
            let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocolDidFinishLoading(self)
        case let .failure(code):
            client?.urlProtocol(self, didFailWithError: URLError(code))
        }
    }

    override func stopLoading() {}
}
