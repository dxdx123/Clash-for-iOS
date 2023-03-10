import Foundation

struct MGConfiguration: Identifiable {
    
    static let key = FileAttributeKey("com.Arror.Mango")
    
    let id: String
    let creationDate: Date
    let attributes: Attributes
}

extension MGConfiguration {
    
    struct Attributes: Codable {
        
        static let key = "Configuration.Attributes"
        
        let alias: String
        let source: URL
        let leastUpdated: Date
    }
}
