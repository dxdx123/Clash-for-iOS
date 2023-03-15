import UIKit
import UserNotifications

extension MGConstant {
    fileprivate static let isAppHasLaunched = "IS_APP_HAS_LAUNCHED"
}

final class MGAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        MGNetworkViewModel.setupDefaultLogIfNeeded()
        MGSniffingViewModel.setupDefaultSettingsIfNeeded()
        MGLogViewModel.setupDefaultLogIfNeeded()
        
        if !UserDefaults.standard.bool(forKey: MGConstant.isAppHasLaunched) {
            
            UserDefaults.shared.set(MGTunnelMode.rule.rawValue, forKey: MGConstant.Clash.tunnelMode)
            UserDefaults.shared.set(MGLogLevel.silent.rawValue, forKey: MGConstant.logLevel)
            UserDefaults.standard.set(MGConstant.Clash.defaultGeoIPDatabaseRemoteURLString, forKey: MGConstant.Clash.geoipDatabaseRemoteURLString)
            UserDefaults.standard.set(true, forKey: MGConstant.Clash.geoipDatabaseAutoUpdate)
            
            UserDefaults.standard.setValue(true, forKey: MGConstant.isAppHasLaunched)
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { _, _ in })
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }
}
