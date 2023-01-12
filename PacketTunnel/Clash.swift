import Foundation
import ClashKit
import os

@frozen enum Clash {
    
    private final class OSLogger: NSObject, ClashLoggerProtocol {
        
        private let raw: Logger
        
        static let shared = OSLogger()
        
        private override init() {
            self.raw = Logger(subsystem: Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String, category: "Clash")
            super.init()
        }
        
        func onLog(_ level: String?, payload: String?) {
            guard let level = level.flatMap(CFILogLevel.init(rawValue:)),
                  let payload = payload, !payload.isEmpty else {
                return
            }
            switch level {
            case .silent:
                break
            case .info, .debug:
                raw.notice("\(payload, privacy: .public)")
            case .warning:
                raw.warning("\(payload, privacy: .public)")
            case .error:
                raw.critical("\(payload, privacy: .public)")
            }
        }
    }
        
    private var current: String {
        UserDefaults.shared.string(forKey: CFIConstant.current) ?? ""
    }
    
    private static var tunnelMode: CFITunnelMode {
        CFITunnelMode(rawValue: UserDefaults.shared.string(forKey: CFIConstant.tunnelMode) ?? "") ?? .rule
    }
    
    private static var logLevel: CFILogLevel {
        CFILogLevel(rawValue: UserDefaults.shared.string(forKey: CFIConstant.logLevel) ?? "") ?? .silent
    }
    
    static func run() throws {
        let port = 8080
        let config = """
        mixed-port: \(port)
        mode: \(tunnelMode.rawValue)
        log-level: \(logLevel.rawValue)
        dns:
            enable: true
            listen: 127.0.0.1:53
            default-nameserver: [223.5.5.5, 119.29.29.29]
            enhanced-mode: fake-ip
            fake-ip-range: 198.18.0.1/16
            use-hosts: true
            nameserver: ['https://doh.pub/dns-query', 'https://dns.alidns.com/dns-query']
            fallback: ['https://doh.dns.sb/dns-query', 'https://dns.cloudflare.com/dns-query', 'https://dns.twnic.tw/dns-query', 'tls://8.8.4.4:853']
            fallback-filter: { geoip: true, ipcidr: [240.0.0.0/4, 0.0.0.0/32] }
        """
        var error: NSError?
        ClashRun(CFIConstant.homeDirectory.path(percentEncoded: false), config, OSLogger.shared, &error)
        if let err = error {
            throw err
        }
        Tun2Socks.run(port: port)
        guard let current = UserDefaults.shared.string(forKey: CFIConstant.current), !current.isEmpty else {
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
    
    static func set(logLevel: CFILogLevel) {
        ClashSetLogLevel(logLevel.rawValue)
    }
    
    static func set(tunnelMode mode: CFITunnelMode) {
        ClashSetTunnelMode(mode.rawValue)
    }
    
    static func healthCheck(provider: String) {
        ClashHealthCheck(provider)
    }
    
    static func fetchProxies() -> Data? {
        ClashGetProxies()
    }
}
