import Foundation

@frozen
public enum MGLogLevel: String, Hashable, Identifiable, CaseIterable, Codable, Comparable {
    
    public var id: Self { self }
    
    case debug, info, warning, error, silent
    
    public static func < (lhs: MGLogLevel, rhs: MGLogLevel) -> Bool {
        lhs.value < rhs.value
    }
    
    private var value: Int {
        switch self {
        case .debug:    return 0
        case .info:     return 1
        case .warning:  return 2
        case .error:    return 3
        case .silent:   return 4
        }
    }
}
