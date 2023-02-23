import Foundation

@frozen public enum MGTunnelMode: String, Hashable, Identifiable, CaseIterable, Codable {
    
    public var id: Self { self }
    
    case global
    case rule
    case direct
}
