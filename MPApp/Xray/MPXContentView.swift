import SwiftUI

struct MPXContentView: View {
        
    @StateObject private var packetTunnelManager    = MPPacketTunnelManager(kernel: .xray)
    
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
                MPSettingButton {
                    NavigationStack {
                        MPXSettingView(packetTunnelManager: packetTunnelManager)
                    }
                }
            }
        }
    }
}
