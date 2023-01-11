import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "254.1.1.1")
        settings.mtu = 1500
        settings.ipv4Settings = {
            let settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.0.0"])
            settings.includedRoutes = [NEIPv4Route.default()]
            return settings
        }()
        settings.dnsSettings = NEDNSSettings(servers: ["114.114.114.114", "8.8.8.8"])
        try await self.setTunnelNetworkSettings(settings)
        try Clash.run()
    }
    
    override func stopTunnel(with reason: NEProviderStopReason) async {
        do {
            try await self.setTunnelNetworkSettings(nil)
        } catch {
            debugPrint(error)
        }
    }
    
    override func handleAppMessage(_ messageData: Data) async -> Data? {
        do {
            switch try JSONDecoder().decode(CFIAppMessage.self, from: messageData) {
            case .subscribe(let current):
                try Clash.set(current: current)
                return nil
            case .mode(let tunnelMode):
                Clash.set(tunnelMode: tunnelMode)
                return nil
            case .proxies:
                return Clash.fetchProxies()
            case .healthCheck(let provider):
                Clash.healthCheck(provider: provider)
                return nil
            case .select(let provider, let proxy):
                Clash.set(provider: provider, selected: proxy)
                return nil
            case .logLevel(let level):
                Clash.set(logLevel: level)
                return nil
            }
        } catch {
            return nil
        }
    }
}

