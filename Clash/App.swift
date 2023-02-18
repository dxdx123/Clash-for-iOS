import SwiftUI

@main
struct CFIApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
        
    @AppStorage(CFIConstant.accentColor) private var accentColor = CFIAccentColor.system
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(accentColor.tint)
        }
    }
}

struct ContentView: View {
    
    @AppStorage(CFIConstant.core) private var core = Core.clash

    var body: some View {
        switch core {
        case .clash:
            ClashContentView(core: $core)
        case .xray:
            XrayContentView(core: $core)
        }
    }
}
