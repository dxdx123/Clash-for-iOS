import NetworkExtension
import XrayKit

@_silgen_name("hev_socks5_tunnel_main") private func hev_socks5_tunnel_main( _ configFilePath: UnsafePointer<CChar>!, _ fd: Int32)

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private var tunnelFileDescriptor: Int32? {
        var buf = Array<CChar>(repeating: 0, count: Int(IFNAMSIZ))
        return (1...1024).first {
            var len = socklen_t(buf.count)
            return getsockopt($0, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun")
        }
    }
    
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
            DispatchQueue.global(qos: .userInitiated).async {
                guard let fd = self.tunnelFileDescriptor else {
                    fatalError()
                }
                guard let path = Bundle.main.path(forResource: "main", ofType: "yml") else {
                    fatalError()
                }
                hev_socks5_tunnel_main(path, fd)
            }
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
