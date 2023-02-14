import UIKit
import UserNotifications

public enum CFINotification {
    
    public enum Level {
        case info, warning, error
        var string: String {
            switch self {
            case .info:
                return ""
            case .warning:
                return "⚠️ "
            case .error:
                return "❌ "
            }
        }
    }
    
    public static func send(level: Level, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(level.string)\(message)"
        content.sound = .defaultRingtone
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "com.Arror.Clash", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
