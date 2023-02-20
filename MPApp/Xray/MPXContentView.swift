import SwiftUI

struct MPXContentView: View {
        
    @StateObject private var packetTunnelManager    = MPPacketTunnelManager(kernel: .xray)
    @StateObject private var databaseManager        = MPCGEOIPManager()
    
    var body: some View {
        Form {
            Section {
                MPControlView(packetTunnelManager: packetTunnelManager)
                MPConnectedDurationView(packetTunnelManager: packetTunnelManager)
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
