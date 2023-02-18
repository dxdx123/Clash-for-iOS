import SwiftUI

@main
struct CFIApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
        
    @AppStorage(CFIConstant.core)           private var core = Core.clash
    @AppStorage(CFIConstant.accentColor)    private var accentColor = CFIAccentColor.system
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch core {
                case .clash:
                    ClashContentView(core: $core)
                case .xray:
                    XrayContentView(core: $core)
                }
            }
            .tint(accentColor.tint)
        }
    }
}
