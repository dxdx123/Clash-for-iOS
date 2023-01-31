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
            UserDefaults.standard.set(CFIConstant.defaultGeoIPDatabaseRemoteURLString, forKey: CFIConstant.geoipDatabaseRemoteURLString)
            UserDefaults.standard.set(true, forKey: CFIConstant.geoipDatabaseAutoUpdate)
            UserDefaults.standard.set(CFIConstant.geoipDatabaseAutoUpdateInterval, forKey: CFIGEOIPAutoUpdateInterval.week.rawValue)
            UserDefaults.standard.set(CFIAccentColor.system.rawValue, forKey: CFIConstant.accentColor)
            UserDefaults.standard.setValue(true, forKey: CFIConstant.isAppHasLaunched)
        }
        geoipManager.checkAndUpdateIfNeeded()
        application.applyAppearance()
        return true
    }
}

extension UIApplication {
    
    func applyAppearance() {
        let current = UserDefaults.standard.string(forKey: CFIConstant.theme).flatMap(CFIAppearance.init(rawValue:)) ?? .system
        self.override(userInterfaceStyle: current.userInterfaceStyle)
    }
    
    private func override(userInterfaceStyle style: UIUserInterfaceStyle) {
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).compactMap({ $0.windows }).flatMap({ $0 }).forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}
