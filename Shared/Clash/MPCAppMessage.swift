import Foundation

@frozen public enum MPCAppMessage: Codable {
    
    case subscribe(String)
    case mode(MPCTunnelMode)
    case proxies
    case healthCheck(String)
    case select(String, String)
    case logLevel(MPCLogLevel)
    
    func data() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
