import UIKit
import UserNotifications

extension MPConstant {
    fileprivate static let isAppHasLaunched = "IS_APP_HAS_LAUNCHED"
}

final class MPAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !UserDefaults.standard.bool(forKey: MPConstant.isAppHasLaunched) {
            UserDefaults.shared.set(MPCTunnelMode.rule.rawValue, forKey: MPConstant.Clash.tunnelMode)
            UserDefaults.shared.set(MPCLogLevel.silent.rawValue, forKey: MPConstant.Clash.logLevel)
            UserDefaults.standard.set(MPConstant.Clash.defaultGeoIPDatabaseRemoteURLString, forKey: MPConstant.Clash.geoipDatabaseRemoteURLString)
            UserDefaults.standard.set(true, forKey: MPConstant.Clash.geoipDatabaseAutoUpdate)
            UserDefaults.standard.set(MPConstant.Clash.geoipDatabaseAutoUpdateInterval, forKey: MPCGEOIPAutoUpdateInterval.week.rawValue)
            UserDefaults.standard.set(MPAccentColor.system.rawValue, forKey: MPConstant.accentColor)
            UserDefaults.standard.setValue(true, forKey: MPConstant.isAppHasLaunched)
        }
        application.overrideUserInterfaceStyle()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { _, _ in })
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension MPAppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }
}

extension UIApplication {
    
    func overrideUserInterfaceStyle() {
        let current = UserDefaults.standard.string(forKey: MPConstant.theme).flatMap(MPAppearance.init(rawValue:)) ?? .system
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
