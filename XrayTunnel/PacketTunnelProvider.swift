import NetworkExtension
import XrayKit
import os

class PacketTunnelProvider: PacketTunnelProviderBase, XrayLoggerProtocol {
    
    private let logger = Logger(subsystem: "com.Arror.Mango.XrayTunnel", category: "Core")
    
    override func setupCore(with settings: NEPacketTunnelNetworkSettings) async throws -> Int {
        guard let id = UserDefaults.shared.string(forKey: "XRAY_CURRENT"), !id.isEmpty else {
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
        return port
    }
    
    func onAccessLog(_ message: String?) {
        message.flatMap { logger.log("\($0, privacy: .public)") }
    }
    
    func onDNSLog(_ message: String?) {
        message.flatMap { logger.log("\($0, privacy: .public)") }
    }
    
    func onGeneralMessage(_ severity: String?, message: String?) {
        let level = severity.flatMap({ _ in MGLogModel.Severity(rawValue: 0) }) ?? .none
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
