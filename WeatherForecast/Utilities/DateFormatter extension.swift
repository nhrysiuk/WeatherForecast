import Foundation

extension DateFormatter {
    static func formatDate(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMM"
            outputFormatter.locale = Locale(identifier: "en_US")
            
            return outputFormatter.string(from: date)
        }
        
        return nil
    }
}
