import Foundation
import Networking
import os

final class StubHTTPClient: HTTPClient {
    private let result: Result<Data, any Error>
    private let recordedRequests = OSAllocatedUnfairLock<[URLRequest]>(initialState: [])

    var requests: [URLRequest] {
        recordedRequests.withLock { $0 }
    }

    init(result: Result<Data, any Error>) {
        self.result = result
    }

    convenience init(json: String) {
        self.init(result: .success(Data(json.utf8)))
    }

    func data(for request: URLRequest) async throws -> Data {
        recordedRequests.withLock { $0.append(request) }
        return try result.get()
    }
}
