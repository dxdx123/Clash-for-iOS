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
        let port: Int = 8080
        let config = """
        mixed-port: \(port)
        mode: \(tunnelMode.rawValue)
        log-level: \(logLevel.rawValue)
        """
        ClashRun(CFIConstant.homeDirectory.path(percentEncoded: false), config, OSLogger.shared)
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
