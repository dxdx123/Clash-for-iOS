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
        if UserDefaults.shared.bool(forKey: MGConstant.Clash.ipv6Enable){
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
            MGNotification.send(title: "", subtitle: "", body: error.localizedDescription)
            throw error
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason) async {
        let message: String
        switch reason {
        case .none:
            message = "No specific reason."
        case .userInitiated:
            message = "The user stopped the provider."
        case .providerFailed:
            message = "The provider failed."
        case .noNetworkAvailable:
            message = "There is no network connectivity."
        case .unrecoverableNetworkChange:
            message = "The device attached to a new network."
        case .providerDisabled:
            message = "The provider was disabled."
        case .authenticationCanceled:
            message = "The authentication process was cancelled."
        case .configurationFailed:
            message = "The provider could not be configured."
        case .idleTimeout:
            message = "The provider was idle for too long."
        case .configurationDisabled:
            message = "The associated configuration was disabled."
        case .configurationRemoved:
            message = "The associated configuration was deleted."
        case .superceded:
            message = "A high-priority configuration was started."
        case .userLogout:
            message = "The user logged out."
        case .userSwitch:
            message = "The active user changed."
        case .connectionFailed:
            message = "Failed to establish connection."
        case .sleep:
            message = "The device went to sleep and disconnectOnSleep is enabled in the configuration."
        case .appUpdate:
            message = "The NEProvider is being updated."
        @unknown default:
            return
        }
        MGNotification.send(title: "", subtitle: "", body: message)
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

