import Foundation
import UniformTypeIdentifiers

extension Bundle {
    
    public static var appID: String {
        Bundle.main.infoDictionary?["APP_ID"] as! String
    }
}

@frozen public enum CFIConstant {
    
    public static let suiteName             = "group.\(Bundle.appID)"
    public static let tunnelMode            = "CLASH_TUNNEL_MODE"
    public static let current               = "CLASH_CURRENT_CONFIG"
    public static let extendAttributeKey    = "CLASH"
    public static let fileAttributeKey      = "NSFileExtendedAttributes"
    
    public static let homeDirectory: URL = {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CFIConstant.suiteName) else {
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

extension UTType {
    public static let yaml: UTType = UTType(__UTTypeYAML.identifier)!
}

extension UserDefaults {
    public static let shared: UserDefaults = UserDefaults(suiteName: CFIConstant.suiteName)!
}

extension FileAttributeKey {
    public static let extended = FileAttributeKey(rawValue: CFIConstant.fileAttributeKey)
}
