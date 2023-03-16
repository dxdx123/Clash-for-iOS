import SwiftUI

@main
struct MGApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: MGAppDelegate
    
    @StateObject private var configurationListManager = MGConfigurationListManager()
    
    var body: some Scene {
        WindowGroup {
            MGHomeView()
                .environmentObject(configurationListManager)
        }
    }
}
