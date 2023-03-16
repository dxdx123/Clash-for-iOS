import NetworkExtension
import XrayKit
import Tun2SocksKit
import os

class PacketTunnelProvider: NEPacketTunnelProvider, XrayLoggerProtocol {
    
    private let logger = Logger(subsystem: "com.Arror.Mango.XrayTunnel", category: "Core")
    
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
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
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "114.114.114.114"])
        try await self.setTunnelNetworkSettings(settings)
        do {
            guard let id = UserDefaults.shared.string(forKey: MGConfiguration.currentStoreKey), !id.isEmpty else {
                fatalError()
            }
            let folderURL = MGConstant.configDirectory.appending(component: id)
            let folderAttributes = try FileManager.default.attributesOfItem(atPath: folderURL.path(percentEncoded: false))
            guard let mapping = folderAttributes[MGConfiguration.key] as? [String: Data],
                  let data = mapping[MGConfiguration.Attributes.key] else {
                fatalError()
            }
            let attributes = try JSONDecoder().decode(MGConfiguration.Attributes.self, from: data)
            let fileURL = folderURL.appending(component: "config.\(attributes.format.rawValue)")
            let log = MGLogModel.current
            XraySetLogger(self)
            XraySetAccessLogEnable(log.accessLogEnabled)
            XraySetDNSLogEnable(log.dnsLogEnabled)
            XraySetErrorLogSeverity(log.errorLogSeverity.rawValue)
            XraySetAsset(MGConstant.assetDirectory.path(percentEncoded: false), nil)
            let port = XrayGetAvailablePort()
            var error: NSError? = nil
            XrayRun(MGSniffingModel.current.generateInboudJSONString(with: port), fileURL.path(percentEncoded: false), &error)
            try error.flatMap { throw $0 }
            
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
    
    func onAccessLog(_ message: String?) {
        message.flatMap { logger.log("\($0, privacy: .public)") }
    }
    
    func onDNSLog(_ message: String?) {
        message.flatMap { logger.log("\($0, privacy: .public)") }
    }
    
    func onGeneralMessage(_ severity: Int, message: String?) {
        let level = MGLogModel.Severity(rawValue: severity) ?? .none
        guard let message = message, !message.isEmpty else {
            return
        }
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        case .none:
            break
        }
    }
}

extension MGSniffingModel {
    
    func generateInboudJSONString(with port: Int) -> String {
        return """
        {
            "listen": "[::1]",
            "protocol": "socks",
            "settings": {
                "udp": true,
                "auth": "noauth"
            },
            "tag": "socks-in",
            "port": \(port),
            "sniffing": {
                "enabled": \(self.enabled ? "true" : "false"),
                "destOverride": [\(self.destOverrideString)],
                "metadataOnly": \(self.metadataOnly ? "true" : "false"),
                "domainsExcluded": [\(self.domainsExcludedString)],
                "routeOnly": \(self.routeOnly ? "true" : "false")
            }
        }
        """
    }
    
    private var domainsExcludedString: String {
        return self.excludedDomains.map({ "\"\($0)\"" }).joined(separator: ", ")
    }
    
    private var destOverrideString: String {
        var temp: [String] = []
        if self.httpEnabled {
            temp.append("http")
        }
        if self.tlsEnabled {
            temp.append("tls")
        }
        if self.quicEnabled {
            temp.append("quic")
        }
        if self.fakednsEnabled {
            temp.append("fakedns")
        }
        if temp.count == 4 {
            temp = ["fakedns+others"]
        }
        return temp.map({ "\"\($0)\"" }).joined(separator: ", ")
    }
}
