import Foundation

public enum NetworkError: Error, Equatable {
    case offline
    case transport(URLError.Code)
    case invalidResponse
    case unacceptableStatusCode(Int)
}
