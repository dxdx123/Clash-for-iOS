import SwiftUI

struct MPXSettingView: View {
    
    let packetTunnelManager: MPPacketTunnelManager
    
    var body: some View {
        Form {
            Section {
                MPAppearanceView()
                MPAccentColorView()
            } header: {
                Text("主题")
            }
            Section {
                MPResetButton(packetTunnelManager: packetTunnelManager)
            }
        }
    }
}
