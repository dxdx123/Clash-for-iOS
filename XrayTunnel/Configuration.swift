import Foundation

struct Configuration {
    
    private var json: [String: Any]
    
    init(id: String) throws {
        let data = try Data(contentsOf: MGKernel.xray.configDirectory.appending(component: "\(id).json"))
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "com.Arror.Mango.XrayTunnel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid config format"])
        }
        self.json = json
    }
    
    mutating func `override`(log level: MGLogLevel) {
        var log: [String: Any] = [:]
        log["access"]    = level == .silent ? "none" : ""
        log["error"]     = level == .silent ? "none" : ""
        log["loglevel"]  = level == .silent ? "none" : level.rawValue
        log["dnsLog"]    = level == .silent ? false  : true
        self.json["log"] = log
    }
    
    mutating func `override`(inbound port: Int) {
        var inbound: [String: Any] = [:]
        inbound["listen"] = "[::1]"
        inbound["port"] = port
        inbound["protocol"] = "socks"
        inbound["settings"] = ["udp" : true]
        inbound["tag"] = "socks-in"
        inbound["sniffing"] = {
            var sniffing: [String: Any] = [:]
            sniffing["enabled"] = UserDefaults.shared.bool(forKey: MGConstant.Xray.sniffingEnable)
            sniffing["destOverride"] = {
                var list: [String] = []
                if UserDefaults.shared.bool(forKey: MGConstant.Xray.sniffingDestOverrideHTTP) {
                    list.append("http")
                }
                if UserDefaults.shared.bool(forKey: MGConstant.Xray.sniffingDestOverrideTLS) {
                    list.append("tls")
                }
                if UserDefaults.shared.bool(forKey: MGConstant.Xray.sniffingDestOverrideQUIC) {
                    list.append("quic")
                }
                if UserDefaults.shared.bool(forKey: MGConstant.Xray.sniffingDestOverrideFAKEDNS) {
                    list.append("fakedns")
                }
                if list.count == 4 {
                    list = ["fakedns+others"]
                }
                return list
            }()
            sniffing["metadataOnly"] = false
            sniffing["domainsExcluded"] = []
            sniffing["routeOnly"] = false
            return sniffing
        }()
        self.json["inbounds"] = [inbound]
    }
    
    func asJSONString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: json)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
