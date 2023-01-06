import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let packetTunnelManager = CFIPacketTunnelManager()
    let subscribeManager    = CFISubscribeManager()
    let geoipManager        = CFIGEOIPManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if UserDefaults.shared.string(forKey: CFIConstant.tunnelMode) == nil {
            UserDefaults.shared.set(CFITunnelMode.rule.rawValue, forKey: CFIConstant.tunnelMode)
        }
        if UserDefaults.shared.string(forKey: CFIConstant.logLevel) == nil {
            UserDefaults.shared.set(CFILogLevel.silent.rawValue, forKey: CFIConstant.logLevel)
        }
        if UserDefaults.standard.string(forKey: CFIConstant.geoipDatabaseRemoteURLString) == nil {
            UserDefaults.standard.set(CFIConstant.defaultGEOIPDatabaseRemoteURLString, forKey: CFIConstant.geoipDatabaseRemoteURLString)
            UserDefaults.standard.set(true, forKey: CFIConstant.geoipDatabaseAutoUpdate)
        }
        geoipManager.checkAndUpdateIfNeeded()
        return true
    }
}
