import Foundation

struct NetworkManager {
    
    func fetch<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WeatherForecastError.networkError
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw WeatherForecastError.invalidResponse
        }
    }
}
