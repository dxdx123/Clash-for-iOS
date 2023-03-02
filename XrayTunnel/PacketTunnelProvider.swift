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
        var config = try Configuration(id: id)
        config.override(level: self.logLevel)
        var error: NSError? = nil
        XrayRun(try config.asJSONString(), self, &error)
        try error.flatMap { throw $0 }
        try Tunnel.start(port: 9090)
    }

    func onLog(_ msg: String?) {
        msg.flatMap { NSLog($0) }
    }
}
