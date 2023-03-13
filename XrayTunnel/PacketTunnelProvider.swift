import NetworkExtension
import XrayKit
import os

class PacketTunnelProvider: MGPacketTunnelProvider, XrayLoggerProtocol {
    
    private let logger = Logger(subsystem: "com.Arror.Mango.XrayTunnel", category: "Core")
        
    private var logLevel: MGLogLevel {
        MGLogLevel(rawValue: UserDefaults.shared.string(forKey: MGConstant.logLevel) ?? "") ?? .silent
    }
    
    override func onTunnelStartCompleted(with settings: NEPacketTunnelNetworkSettings) async throws {
        guard let id = UserDefaults.shared.string(forKey: "\(MGKernel.xray.rawValue.uppercased())_CURRENT"), !id.isEmpty else {
            fatalError()
        }
        let folderURL = MGKernel.xray.configDirectory.appending(component: id)
        let folderAttributes = try FileManager.default.attributesOfItem(atPath: folderURL.path(percentEncoded: false))
        guard let mapping = folderAttributes[MGConfiguration.key] as? [String: Data],
              let data = mapping[MGConfiguration.Attributes.key] else {
            fatalError()
        }
        let attributes = try JSONDecoder().decode(MGConfiguration.Attributes.self, from: data)
        let fileURL = folderURL.appending(component: "config.\(attributes.format.rawValue)")
        XraySetAccessLogEnable(false)
        XraySetDNSLogEnable(false)
        XraySetErrorLogSeverity(4)
        XraySetLogger(self)
        XraySetAsset(MGKernel.xray.assetDirectory.path(percentEncoded: false), nil)
        let port = XrayGetAvailablePort()
        let inbound = """
        {
            "listen": "[::1]",
            "protocol": "socks",
            "settings": {
                "udp": true,
                "auth": "noauth"
            },
            "tag": "socks-in",
            "port": \(port)
        }
        """
        var error: NSError? = nil
        XrayRun(inbound, fileURL.path(percentEncoded: false), &error)
        try error.flatMap { throw $0 }
        try Tunnel.start(port: port)
    }
    
    func onAccessLog(_ message: String?) {
        message.flatMap { logger.log("\($0, privacy: .public)") }
    }
    
    func onDNSLog(_ message: String?) {
        message.flatMap { logger.log("\($0, privacy: .public)") }
    }
    
    func onGeneralMessage(_ severity: String?, message: String?) {
        let level = severity.flatMap({ MGLogLevel(rawValue: $0.lowercased()) }) ?? .silent
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
        case .silent:
            break
        }
    }
}
