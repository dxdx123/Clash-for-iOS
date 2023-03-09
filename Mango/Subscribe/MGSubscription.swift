import Foundation

struct MGSubscription: Identifiable {
    
    static let key = FileAttributeKey("com.Arror.Mango")
    
    let id: String
    let creationDate: Date
    let attributes: MGAttributes
}
