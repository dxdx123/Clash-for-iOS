import Foundation
import ClashKit
import os

@frozen enum Clash {
    
    private final class Client: NSObject, ClashClientProtocol {
        
        private let logger: Logger
        
        static let shared = Client()
        
        private override init() {
            self.logger = Logger(subsystem: Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String, category: "Clash")
            super.init()
        }
        
        func onLog(_ level: String?, payload: String?) {
            guard let level = level.flatMap(MGLogLevel.init(rawValue:)),
                  let payload = payload, !payload.isEmpty else {
                return
            }
            switch level {
            case .silent:
                break
            case .info, .debug:
                logger.notice("\(payload, privacy: .public)")
            case .warning:
                logger.warning("\(payload, privacy: .public)")
            case .error:
                logger.critical("\(payload, privacy: .public)")
            }
        }
        
        func onTraffic(_ up: Int64, down: Int64) {
            UserDefaults.shared.set(up, forKey: MGConstant.Clash.trafficUp)
            UserDefaults.shared.set(down, forKey: MGConstant.Clash.trafficDown)
        }
    }
        
    private var current: String {
        UserDefaults.shared.string(forKey: MGConstant.Clash.current) ?? ""
    }
    
    private static var tunnelMode: MGTunnelMode {
        MGTunnelMode(rawValue: UserDefaults.shared.string(forKey: MGConstant.Clash.tunnelMode) ?? "") ?? .rule
    }
    
    private static var logLevel: MGLogLevel {
        MGLogLevel(rawValue: UserDefaults.shared.string(forKey: MGConstant.Clash.logLevel) ?? "") ?? .silent
    }
    
    private static var isIPv6Enabel: Bool {
        UserDefaults.shared.bool(forKey: MGConstant.Clash.ipv6Enable)
    }
    
    private static var tunnelFileDescriptor: Int32? {
        var buf = Array<CChar>(repeating: 0, count: Int(IFNAMSIZ))
        return (1...1024).first {
            var len = socklen_t(buf.count)
            return getsockopt($0, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun")
        }
    }
    
    static func run() throws {
        let config = """
        mode: \(tunnelMode.rawValue)
        log-level: \(logLevel.rawValue)
        ipv6: \(isIPv6Enabel ? "true" : "false")
        dns:
            enable: true
            listen: 127.0.0.1:53
            ipv6: \(isIPv6Enabel ? "true" : "false")
            default-nameserver: [223.5.5.5, 119.29.29.29]
            enhanced-mode: fake-ip
            fake-ip-range: 198.18.0.1/16
            nameserver: ['https://doh.pub/dns-query', 'https://dns.alidns.com/dns-query']
            fallback: ['https://doh.dns.sb/dns-query', 'https://dns.cloudflare.com/dns-query', 'https://dns.twnic.tw/dns-query', 'tls://8.8.4.4:853']
            fallback-filter: { geoip: true, ipcidr: [240.0.0.0/4, 0.0.0.0/32] }
        rules:
            - MATCH,DIRECT
        """
        guard let fd = tunnelFileDescriptor else {
            fatalError("Get tunnel file descriptor failed.")
        }
        var err: NSError? = nil
        ClashRun(Int(fd), MGConstant.Clash.homeDirectory.path(percentEncoded: false), config, Client.shared, &err)
        try err.flatMap { throw $0 }
        guard let current = UserDefaults.shared.string(forKey: MGConstant.Clash.current), !current.isEmpty else {
            return
        }
        try Clash.set(current: current)
    }
    
    static func set(current config: String) throws {
        var err: NSError?
        guard !ClashSetConfig(config, &err), let err = err else {
            return
        }
        throw err
    }
    
    static func set(provider: String, selected proxy: String) {
        ClashSetSelect(provider, proxy)
    }
    
    static func set(logLevel: MGLogLevel) {
        ClashSetLogLevel(logLevel.rawValue)
    }
    
    static func set(tunnelMode mode: MGTunnelMode) {
        ClashSetTunnelMode(mode.rawValue)
    }
    
    static func healthCheck(provider: String) {
        ClashHealthCheck(provider)
    }
    
    static func fetchProxies() -> Data? {
        ClashGetProxies()
    }
}
