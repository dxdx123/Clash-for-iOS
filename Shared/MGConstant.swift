import Foundation
import UniformTypeIdentifiers

@frozen public enum MGConstant {
    
    public static let suiteName = "group.\(Bundle.appID)"
    
    private static func createDirectory(at url: URL) -> URL {
        guard FileManager.default.fileExists(atPath: url.path) == false else {
            return url
        }
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        return url
    }

    public static let homeDirectory: URL = {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: MGConstant.suiteName) else {
            fatalError("无法加载共享文件路径")
        }
        let url = containerURL.appendingPathComponent("Library/Application Support/Xray")
        return MGConstant.createDirectory(at: url)
    }()
    
    public static let assetDirectory = MGConstant.createDirectory(at: MGConstant.homeDirectory.appending(component: "assets", directoryHint: .isDirectory))
    
    public static let configDirectory = MGConstant.createDirectory(at: MGConstant.homeDirectory.appending(component: "configs", directoryHint: .isDirectory))
}

extension Bundle {
    
    public static var appID: String {
        Bundle.main.infoDictionary?["APP_ID"] as! String
    }
    
    public static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    public static var providerBundleIdentifier: String {
        return "\(Bundle.appID).\(Bundle.main.infoDictionary?["TUNNEL_BUNDLE_SUFFIX_XRAY"] as! String)"
    }
}

extension UTType {
    
    public static let toml  : UTType = UTType(filenameExtension: "toml")!
    
    public static let mmdb  : UTType = UTType(filenameExtension: "mmdb")!
    
    public static let dat   : UTType = UTType(filenameExtension: "dat")!
}

extension UserDefaults {
    
    public static let shared: UserDefaults = UserDefaults(suiteName: MGConstant.suiteName)!
}

extension NSError {
    
    public static func newError(_ message: String) -> NSError {
        NSError(domain: "com.Arror.Mango", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
