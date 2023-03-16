import SwiftUI

@main
struct MGApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: MGAppDelegate
    
    var body: some Scene {
        WindowGroup {
            MGContentView()
        }
    }
}
