import Foundation

@frozen public enum MGAppMessage: Codable {
    
    case subscribe(String)
    case mode(MGTunnelMode)
    case proxies
    case healthCheck(String)
    case select(String, String)
    case logLevel(MGLogLevel)
    
    func data() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
