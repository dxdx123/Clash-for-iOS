import UIKit
import UserNotifications

extension CFIConstant {
    fileprivate static let isAppHasLaunched = "IS_APP_HAS_LAUNCHED"
}

final class MPAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !UserDefaults.standard.bool(forKey: CFIConstant.isAppHasLaunched) {
            UserDefaults.shared.set(CFITunnelMode.rule.rawValue, forKey: CFIConstant.tunnelMode)
            UserDefaults.shared.set(CFILogLevel.silent.rawValue, forKey: CFIConstant.logLevel)
            UserDefaults.standard.set(CFIConstant.defaultGeoIPDatabaseRemoteURLString, forKey: CFIConstant.geoipDatabaseRemoteURLString)
            UserDefaults.standard.set(true, forKey: CFIConstant.geoipDatabaseAutoUpdate)
            UserDefaults.standard.set(CFIConstant.geoipDatabaseAutoUpdateInterval, forKey: CFIGEOIPAutoUpdateInterval.week.rawValue)
            UserDefaults.standard.set(MPAccentColor.system.rawValue, forKey: CFIConstant.accentColor)
            UserDefaults.standard.setValue(true, forKey: CFIConstant.isAppHasLaunched)
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
        let current = UserDefaults.standard.string(forKey: CFIConstant.theme).flatMap(MPAppearance.init(rawValue:)) ?? .system
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
