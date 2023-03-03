import NetworkExtension
import XrayKit
import TunnelKit

class PacketTunnelProvider: MGPacketTunnelProvider, XrayLoggerProtocol {
    
    private var logLevel: MGLogLevel {
        MGLogLevel(rawValue: UserDefaults.shared.string(forKey: MGConstant.logLevel) ?? "") ?? .silent
    }
    
    override func onTunnelStartCompleted(with settings: NEPacketTunnelNetworkSettings) async throws {
        guard let id = UserDefaults.shared.string(forKey: "\(MGKernel.xray.rawValue.uppercased())_CURRENT"), !id.isEmpty else {
            fatalError()
        }
        XraySetAsset(MGKernel.xray.assetDirectory.path(percentEncoded: false), nil)
        let port = XrayGetAvailablePort("tcp", "[::1]:0")
        var config = try Configuration(id: id)
        config.override(log: self.logLevel)
        config.override(inbound: port)
        var error: NSError? = nil
        XrayRun(try config.asJSONString(), self, &error)
        try error.flatMap { throw $0 }
        try Tunnel.start(port: port)        
    }

    func onLog(_ msg: String?) {
        msg.flatMap { NSLog($0) }
    }
}
