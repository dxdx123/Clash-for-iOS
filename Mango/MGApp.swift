import SwiftUI

@main
struct MGApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: MGAppDelegate
    
    @StateObject private var configurationListManager = MGConfigurationListManager()
    
    @AppStorage(MGKernel.storeKey) private var kernel = MGKernel.clash
    
    var body: some Scene {
        WindowGroup {
            MGHomeView(kernel: $kernel)
                .environmentObject(configurationListManager)
        }
    }
}
