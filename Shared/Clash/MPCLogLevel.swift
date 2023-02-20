import Foundation

@frozen
public enum MPCLogLevel: String, Hashable, Identifiable, CaseIterable, Codable {
    
    public var id: Self { self }
    
    case debug
    case info
    case warning
    case error
    case silent
}
