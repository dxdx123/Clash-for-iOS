import SwiftUI

struct MPXSettingView: View {
    
    let packetTunnelManager: MPPacketTunnelManager
    
    var body: some View {
        Form {
            Section {
                MGAppearanceView()
            } header: {
                Text("主题")
            }
            Section {
                MPResetButton(packetTunnelManager: packetTunnelManager)
            }
        }
    }
}
