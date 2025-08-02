import Foundation

struct CoordinateData: Codable, Equatable {
    
    let latitude, longitude: Double
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
        case name
    }
    
}
