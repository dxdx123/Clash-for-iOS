import NetworkExtension

open class MGPacketTunnelProvider: NEPacketTunnelProvider {
    
    open var isIPv4Enable: Bool { true }
    open var isIPv6Enable: Bool {
        UserDefaults.shared.bool(forKey: MGConstant.ipv6Enable)
    }
    open var dnsServers: [String] { ["8.8.8.8", "114.114.114.114"] }
    
    public final override func startTunnel(options: [String : NSObject]? = nil) async throws {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "254.1.1.1")
        settings.mtu = 9000
        
        settings.ipv4Settings = {
            guard self.isIPv4Enable else {
                return nil
            }
            let settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.0.0"])
            settings.includedRoutes = [NEIPv4Route.default()]
            return settings
        }()
        settings.ipv6Settings = {
            guard self.isIPv6Enable else {
                return nil
            }
            let settings = NEIPv6Settings(addresses: ["fd6e:a81b:704f:1211::1"], networkPrefixLengths: [64])
            settings.includedRoutes = [NEIPv6Route.default()]
            return settings
        }()
        settings.dnsSettings = NEDNSSettings(servers: self.dnsServers)
        try await self.setTunnelNetworkSettings(settings)
        do {
            try await self.onTunnelStartCompleted(with: settings)
        } catch {
            MGNotification.send(title: "", subtitle: "", body: error.localizedDescription)
            throw error
        }
    }
    
    open func onTunnelStartCompleted(with settings: NEPacketTunnelNetworkSettings) async throws {}
    
    open override func stopTunnel(with reason: NEProviderStopReason) async {
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
    
    open override func handleAppMessage(_ messageData: Data) async -> Data? {
        return nil
    }
}
