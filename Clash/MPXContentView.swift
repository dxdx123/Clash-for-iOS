import SwiftUI

struct MPXContentView: View {
        
    @StateObject private var packetTunnelManager    = MPPacketTunnelManager(kernel: .xray)
    @StateObject private var databaseManager        = CFIGEOIPManager()
    
    var body: some View {
        Form {
            Section {
                CFIControlView(packetTunnelManager: packetTunnelManager)
                CFIConnectedDurationView(packetTunnelManager: packetTunnelManager)
            } header: {
                Text("状态")
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                MPSettingButton(packetTunnelManager: packetTunnelManager)
            }
        }
    }
}
