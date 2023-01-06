import SwiftUI

@main
struct CFIApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
    
    @AppStorage(CFIConstant.theme) private var theme = CFITheme.system
    @AppStorage(CFIConstant.accentColor) private var accentColor = CFIAccentColor.blue
    
    var body: some Scene {
        WindowGroup {
            CFIContentView()
                .environmentObject(delegate.packetTunnelManager)
                .environmentObject(delegate.subscribeManager)
                .environmentObject(delegate.geoipManager)
                .preferredColorScheme(theme.preferredColorScheme)
                .tint(accentColor.rawColor)
        }
    }
}
