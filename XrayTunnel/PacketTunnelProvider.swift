import NetworkExtension
import XrayKit
import TunnelKit

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        XraySetAsset(MGKernel.xray.assetDirectory.path(percentEncoded: false), nil)
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "254.1.1.1")
        settings.mtu = 9000
        settings.ipv4Settings = {
            let settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.0.0"])
            settings.includedRoutes = [NEIPv4Route.default()]
            return settings
        }()
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "114.114.114.114"])
        try await self.setTunnelNetworkSettings(settings)
        guard let id = UserDefaults.shared.string(forKey: "\(MGKernel.xray.rawValue.uppercased())_CURRENT"), !id.isEmpty else {
            return
        }
        do {
            let config = try String(contentsOfFile: MGKernel.xray.configDirectory.appending(component: "\(id).json").path(percentEncoded: false))
            var error: NSError? = nil
            XrayRun(config, self, &error)
            try error.flatMap { throw $0 }
            try Tunnel.start(port: 9090)
        } catch {
            throw error
        }
    }
}

extension PacketTunnelProvider: XrayLoggerProtocol {

    func onLog(_ msg: String?) {
        msg.flatMap { NSLog($0) }
    }
}
