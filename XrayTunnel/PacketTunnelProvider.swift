import NetworkExtension
import XrayKit
import os

class PacketTunnelProvider: MGPacketTunnelProvider, XrayLoggerProtocol {
    
    private let logger = Logger(subsystem: "com.Arror.Mango.XrayTunnel", category: "core")
        
    private var logLevel: MGLogLevel {
        MGLogLevel(rawValue: UserDefaults.shared.string(forKey: MGConstant.logLevel) ?? "") ?? .silent
    }
    
    override func onTunnelStartCompleted(with settings: NEPacketTunnelNetworkSettings) async throws {
        guard let id = UserDefaults.shared.string(forKey: "\(MGKernel.xray.rawValue.uppercased())_CURRENT"), !id.isEmpty else {
            fatalError()
        }
        XraySetAsset(MGKernel.xray.assetDirectory.path(percentEncoded: false), nil)
        let port = XrayGetAvailablePort()
        let base = """
        {
            "log": {
                "access": "none",
                "error": "none",
                "loglevel": "none",
                "dnsLog": false
            },
            "inbounds": [
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
            ],
            "outbounds": [
                {
                    "protocol": "freedom",
                    "tag": "direct"
                }
            ]
        }
        """
        var error: NSError? = nil
        XrayRun(
            base,
            MGKernel.xray.configDirectory.appending(component: "\(id).json").path(percentEncoded: false),
            self,
            &error
        )
        try error.flatMap { throw $0 }
        try Tunnel.start(port: port)
    }
    
    func onAccessLog(_ message: String?) {}
    
    func onDNSLog(_ message: String?) {}
    
    func onGeneralMessage(_ severity: String?, message: String?) {
        let level = severity.flatMap({ MGLogLevel(rawValue: $0.lowercased()) }) ?? .silent
        guard level >= logLevel, let message = message, !message.isEmpty else {
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
