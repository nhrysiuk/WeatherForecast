import Domain
import Foundation
import Networking
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WeatherForecast", category: "OpenMeteo")

extension HTTPClient {
    func response<Response: Decodable & Sendable>(
        _ type: Response.Type,
        for request: URLRequest
    ) async throws -> Response {
        let data: Data
        do {
            data = try await self.data(for: request)
        } catch NetworkError.offline {
            throw WeatherError.offline
        } catch let error as CancellationError {
            throw error
        } catch {
            logger.error("Request failed: \(String(describing: error), privacy: .public)")
            throw WeatherError.server
        }
        do {
            return try await decode(type, from: data)
        } catch {
            logger.error("Decoding \(String(describing: type), privacy: .public) failed: \(String(describing: error), privacy: .public)")
            throw WeatherError.server
        }
    }
}

@concurrent
private func decode<Response: Decodable & Sendable>(
    _ type: Response.Type,
    from data: Data
) async throws -> Response {
    try JSONDecoder().decode(type, from: data)
}
