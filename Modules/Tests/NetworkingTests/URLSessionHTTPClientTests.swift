import Foundation
import Networking
import Testing

struct URLSessionHTTPClientTests {
    @Test(arguments: [200, 299])
    func returnsDataOfSuccessfulResponse(statusCode: Int) async throws {
        let body = Data(#"{"latitude":52.23}"#.utf8)
        let (client, request) = StubURLProtocol.client(stubbing: .response(statusCode: statusCode, data: body))

        #expect(try await client.data(for: request) == body)
    }

    @Test(arguments: [300, 400, 404, 500])
    func rejectsUnacceptableStatusCodes(statusCode: Int) async {
        let (client, request) = StubURLProtocol.client(stubbing: .response(statusCode: statusCode, data: Data()))

        await #expect(throws: NetworkError.unacceptableStatusCode(statusCode)) {
            try await client.data(for: request)
        }
    }

    @Test func rejectsNonHTTPResponse() async {
        let (client, request) = StubURLProtocol.client(stubbing: .nonHTTPResponse)

        await #expect(throws: NetworkError.invalidResponse) {
            try await client.data(for: request)
        }
    }

    @Test(arguments: [
        URLError.Code.notConnectedToInternet,
        .networkConnectionLost,
        .dataNotAllowed,
        .internationalRoamingOff,
    ])
    func reportsOfflineForConnectivityErrors(code: URLError.Code) async {
        let (client, request) = StubURLProtocol.client(stubbing: .failure(code))

        await #expect(throws: NetworkError.offline) {
            try await client.data(for: request)
        }
    }

    @Test func turnsCancelledRequestIntoCancellationError() async {
        let (client, request) = StubURLProtocol.client(stubbing: .failure(.cancelled))

        await #expect(throws: CancellationError.self) {
            try await client.data(for: request)
        }
    }

    @Test func wrapsOtherTransportErrors() async {
        let (client, request) = StubURLProtocol.client(stubbing: .failure(.timedOut))

        await #expect(throws: NetworkError.transport(.timedOut)) {
            try await client.data(for: request)
        }
    }
}
