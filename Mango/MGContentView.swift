import SwiftUI

struct MGContentView: View {
    
    @StateObject private var packetTunnelManager        = MGPacketTunnelManager()
    @StateObject private var configurationListManager   = MGConfigurationListManager()
    
    @AppStorage(MGConfiguration.currentStoreKey, store: .shared) private var current: String = ""
    
    var body: some View {
        TabView {
            MGHomeView(current: $current)
                .tabItem {
                    Text("仪表盘")
                    Image(systemName: "text.and.command.macwindow")
                }
            MGConfigurationListView(current: $current)
                .tabItem {
                    Text("配置管理")
                    Image(systemName: "doc")
                }
            MGSettingView()
                .tabItem {
                    Text("设置")
                    Image(systemName: "gearshape")
                }
        }
        .environmentObject(packetTunnelManager)
        .environmentObject(configurationListManager)
    }
}
