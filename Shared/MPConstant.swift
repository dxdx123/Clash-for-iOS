import Foundation
import UniformTypeIdentifiers

@frozen public enum MPConstant {
    @frozen public enum Clash   {}
    @frozen public enum Xray    {}
}

extension MPConstant {
    public static let suiteName = "group.\(Bundle.appID)"
}

extension MPConstant.Clash {
    
    public static let tunnelMode            = "CLASH_TUNNEL_MODE"
    public static let logLevel              = "CLASH_LOGLEVEL"
    public static let current               = "CLASH_CURRENT_CONFIG"
    public static let extendAttributeKey    = "CLASH"
    public static let fileAttributeKey      = "NSFileExtendedAttributes"
    public static let trafficUp             = "CLASH_TRAFFIC_UP"
    public static let trafficDown           = "CLASH_TRAFFIC_DOWN"
    public static let ipv6Enable            = "CLASH_IPV6_ENABLE"

    public static let homeDirectory: URL = {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: MPConstant.suiteName) else {
            fatalError("无法加载共享文件路径")
        }
        let url = containerURL.appendingPathComponent("Library/Application Support/Clash")
        guard FileManager.default.fileExists(atPath: url.path) == false else {
            return url
        }
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        return url
    }()
}

extension Bundle {
    public static var appID: String {
        Bundle.main.infoDictionary?["APP_ID"] as! String
    }
}

extension UTType {
    public static let yaml: UTType = UTType(__UTTypeYAML.identifier)!
}

extension UserDefaults {
    public static let shared: UserDefaults = UserDefaults(suiteName: MPConstant.suiteName)!
}

extension FileAttributeKey {
    public static let extended = FileAttributeKey(rawValue: MPConstant.Clash.fileAttributeKey)
}
