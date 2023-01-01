import SwiftUI

@main
struct CFIApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            CFIContentView()
                .environmentObject(delegate.packetTunnelManager)
                .environmentObject(delegate.subscribeManager)
        }
    }
}
