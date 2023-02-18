import UIKit
import UserNotifications

public enum MPNotification {
    
    public static func send(title: String, subtitle: String, body: String) {
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: "com.Arror.Clash",
                content: {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.subtitle = subtitle
                    content.body = body
                    return content
                }(),
                trigger: UNTimeIntervalNotificationTrigger(
                    timeInterval: 0.1,
                    repeats: false
                )
            )
        )
    }
}
