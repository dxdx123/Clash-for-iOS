import Foundation

struct MGAttributes: Codable {
    
    static let key = "Subscription.Attributes"
    
    let alias: String
    let source: URL
    let leastUpdated: Date
}
