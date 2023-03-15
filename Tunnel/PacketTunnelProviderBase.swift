import NetworkExtension
import Tun2SocksKit

open class PacketTunnelProviderBase: NEPacketTunnelProvider {
    
    open var dnsServers: [String] { ["8.8.8.8", "114.114.114.114"] }
    
    public final override func startTunnel(options: [String : NSObject]? = nil) async throws {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "254.1.1.1")
        settings.mtu = 9000
        let netowrk = MGNetworkModel.current
        settings.ipv4Settings = {
            let settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.0.0"])
            settings.includedRoutes = [NEIPv4Route.default()]
            if netowrk.hideVPNIcon {
                settings.excludedRoutes = [NEIPv4Route(destinationAddress: "0.0.0.0", subnetMask: "255.0.0.0")]
            }
            return settings
        }()
        settings.ipv6Settings = {
            guard netowrk.ipv6Enabled else {
                return nil
            }
            let settings = NEIPv6Settings(addresses: ["fd6e:a81b:704f:1211::1"], networkPrefixLengths: [64])
            settings.includedRoutes = [NEIPv6Route.default()]
            if netowrk.hideVPNIcon {
                settings.excludedRoutes = [NEIPv6Route(destinationAddress: "::", networkPrefixLength: 64)]
            }
            return settings
        }()
        settings.dnsSettings = NEDNSSettings(servers: self.dnsServers)
        try await self.setTunnelNetworkSettings(settings)
        let port = try await self.setupCore(with: settings)
        guard port > 0 else {
            return
        }
        do {
            let config = """
            tunnel:
              mtu: 9000
            socks5:
              port: \(port)
              address: ::1
              udp: 'udp'
            misc:
              task-stack-size: 20480
              connect-timeout: 5000
              read-write-timeout: 60000
              log-file: stderr
              log-level: error
              limit-nofile: 65535
            """
            let cache = URL(filePath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0], directoryHint: .isDirectory)
            let file = cache.appending(component: "\(UUID().uuidString).yml", directoryHint: .notDirectory)
            try config.write(to: file, atomically: true, encoding: .utf8)
            DispatchQueue.global(qos: .userInitiated).async {
                NSLog("HEV_SOCKS5_TUNNEL_MAIN: \(Socks5Tunnel.run(withConfig: file.path(percentEncoded: false)))")
            }
        } catch {
            MGNotification.send(title: "", subtitle: "", body: error.localizedDescription)
            throw error
        }
    }
    
    open func setupCore(with settings: NEPacketTunnelNetworkSettings) async throws -> Int {
        fatalError()
    }
    
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
