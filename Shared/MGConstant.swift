import Foundation
import UniformTypeIdentifiers

@frozen public enum MGConstant {}

extension MGConstant {
    public static let suiteName = "group.\(Bundle.appID)"
    public static let logLevel  = "LOGLEVEL"

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
    public static let yaml: UTType = UTType(__UTTypeYAML.identifier)!
}

extension UserDefaults {
    public static let shared: UserDefaults = UserDefaults(suiteName: MGConstant.suiteName)!
}
