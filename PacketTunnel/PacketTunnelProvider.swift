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
        if UserDefaults.shared.bool(forKey: CFIConstant.ipv6Enable){
            settings.ipv6Settings = {
                let settings = NEIPv6Settings(addresses: ["fd6e:a81b:704f:1211::1"], networkPrefixLengths: [64])
                settings.includedRoutes = [NEIPv6Route.default()]
                return settings
            }()
        }
        settings.dnsSettings = NEDNSSettings(servers: ["127.0.0.1"])
        try await self.setTunnelNetworkSettings(settings)
        do {
            try Clash.run()
        } catch {
            CFINotification.send(title: "", subtitle: "", body: error.localizedDescription)
            throw error
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason) async {
        do {
            try await self.setTunnelNetworkSettings(nil)
        } catch {
            CFINotification.send(title: "", subtitle: "", body: error.localizedDescription)
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

