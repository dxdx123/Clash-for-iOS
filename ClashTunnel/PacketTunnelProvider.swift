import NetworkExtension

class PacketTunnelProvider: PacketTunnelProviderBase {
    
    override var dnsServers: [String] { ["127.0.0.1"] }
    
    override func setupCore(with settings: NEPacketTunnelNetworkSettings) async throws -> Int {
        try Clash.run(ipv6Enabled: settings.ipv6Settings != nil)
        return 0
    }

    override func handleAppMessage(_ messageData: Data) async -> Data? {
        do {
            switch try JSONDecoder().decode(MGAppMessage.self, from: messageData) {
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

