import UIKit
import UserNotifications

public enum MGNotification {
    
    public static func send(title: String, subtitle: String, body: String) {
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: "com.Arror.Mango",
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
