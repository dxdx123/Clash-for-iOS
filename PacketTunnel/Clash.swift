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
            guard let level = level.flatMap(CFILogLevel.init(rawValue:)),
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
            UserDefaults.shared.set(up, forKey: CFIConstant.trafficUp)
            UserDefaults.shared.set(down, forKey: CFIConstant.trafficDown)
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
    
    private static var tunnelFileDescriptor: Int32? {
        var buf = Array<CChar>(repeating: 0, count: Int(IFNAMSIZ))
        return (1...1024).first {
            var len = socklen_t(buf.count)
            return getsockopt($0, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun")
        }
    }
    
    static func run() throws {
        let config = """
        mixed-port: 8080
        mode: \(tunnelMode.rawValue)
        log-level: \(logLevel.rawValue)
        rules:
            - MATCH,DIRECT
        """
        guard let fd = tunnelFileDescriptor else {
            fatalError("Get tunnel file descriptor failed.")
        }
        print(fd)
        // fd 传 0，用于禁用ClashKit内部的tun实现
        ClashRun(0, CFIConstant.homeDirectory.path(percentEncoded: false), config, Client.shared)
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
