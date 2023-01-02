import SwiftUI

@main
struct CFIApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
    
    @AppStorage(CFIConstant.theme) private var theme = CFITheme.system
    
    var body: some Scene {
        WindowGroup {
            CFIContentView()
                .environmentObject(delegate.packetTunnelManager)
                .environmentObject(delegate.subscribeManager)
                .preferredColorScheme(theme.preferredColorScheme)
        }
    }
}
