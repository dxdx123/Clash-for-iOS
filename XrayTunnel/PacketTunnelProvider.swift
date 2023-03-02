import NetworkExtension
import XrayKit
import TunnelKit

class PacketTunnelProvider: MGPacketTunnelProvider, XrayLoggerProtocol {
    
    override func onTunnelStartCompleted(with settings: NEPacketTunnelNetworkSettings) async throws {
        guard let id = UserDefaults.shared.string(forKey: "\(MGKernel.xray.rawValue.uppercased())_CURRENT"), !id.isEmpty else {
            fatalError()
        }
        XraySetAsset(MGKernel.xray.assetDirectory.path(percentEncoded: false), nil)
        let config = try String(contentsOfFile: MGKernel.xray.configDirectory.appending(component: "\(id).json").path(percentEncoded: false))
        var error: NSError? = nil
        XrayRun(config, self, &error)
        try error.flatMap { throw $0 }
        try Tunnel.start(port: 9090)
    }

    func onLog(_ msg: String?) {
        msg.flatMap { NSLog($0) }
    }
}
