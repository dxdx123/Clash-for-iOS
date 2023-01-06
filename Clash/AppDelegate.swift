import UIKit

extension CFIConstant {
    fileprivate static let isAppHasLaunched = "IS_APP_HAS_LAUNCHED"
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let packetTunnelManager = CFIPacketTunnelManager()
    let subscribeManager    = CFISubscribeManager()
    let geoipManager        = CFIGEOIPManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !UserDefaults.standard.bool(forKey: CFIConstant.isAppHasLaunched) {
            UserDefaults.shared.set(CFITunnelMode.rule.rawValue, forKey: CFIConstant.tunnelMode)
            UserDefaults.shared.set(CFILogLevel.silent.rawValue, forKey: CFIConstant.logLevel)
            UserDefaults.standard.set(CFIConstant.defaultGEOIPDatabaseRemoteURLString, forKey: CFIConstant.geoipDatabaseRemoteURLString)
            UserDefaults.standard.set(true, forKey: CFIConstant.geoipDatabaseAutoUpdate)
            UserDefaults.standard.set(CFIConstant.geoipDatabaseAutoUpdateInterval, forKey: CFIGEOIPAutoUpdateInterval.week.rawValue)
            UserDefaults.standard.setValue(true, forKey: CFIConstant.isAppHasLaunched)
        }
        geoipManager.checkAndUpdateIfNeeded()
        return true
    }
}
