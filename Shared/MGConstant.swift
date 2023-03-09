import Foundation
import UniformTypeIdentifiers

@frozen public enum MGConstant {}

extension MGConstant {
    public static let suiteName     = "group.\(Bundle.appID)"
    public static let logLevel      = "LOGL_EVEL"
    public static let ipv6Enable    = "IPV6_ENABLE"
}

extension Bundle {
    public static var appID: String {
        Bundle.main.infoDictionary?["APP_ID"] as! String
    }
    public static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
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
