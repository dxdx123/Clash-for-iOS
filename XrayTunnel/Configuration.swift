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
    
    mutating func `override`(level: MGLogLevel) {
        var config: [String: Any] = [:]
        config["access"]    = level == .silent ? "none" : ""
        config["error"]     = level == .silent ? "none" : ""
        config["loglevel"]  = level == .silent ? "none" : level.rawValue
        config["dnsLog"]    = level == .silent ? false  : true
        self.json["log"] = config
    }
    
    func asJSONString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: json)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
