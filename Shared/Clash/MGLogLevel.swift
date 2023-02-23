import Foundation

@frozen
public enum MGLogLevel: String, Hashable, Identifiable, CaseIterable, Codable {
    
    public var id: Self { self }
    
    case debug
    case info
    case warning
    case error
    case silent
}
