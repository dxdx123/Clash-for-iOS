import Foundation

@frozen public enum CFITunnelMode: String, Hashable, Identifiable, CaseIterable, Codable {
    
    public var id: Self { self }
    
    case global
    case rule
    case direct
}
