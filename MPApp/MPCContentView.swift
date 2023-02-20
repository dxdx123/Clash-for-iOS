import SwiftUI
import NetworkExtension

struct MPCContentView: View {
        
    @AppStorage(MPConstant.Clash.current, store: .shared) private var current = ""
    
    @StateObject private var packetTunnelManager    = MPPacketTunnelManager(kernel: .clash)
    @StateObject private var subscribeManager       = MPCSubscribeManager()
    @StateObject private var databaseManager        = MPCGEOIPManager()
    
    var body: some View {
        Form {
            Section {
                MPCSubscribeView(current: $current, packetTunnelManager: packetTunnelManager, subscribeManager: subscribeManager)
            } header: {
                Text("订阅")
            }
            Section {
                MPControlView(packetTunnelManager: packetTunnelManager)
                MPConnectedDurationView(packetTunnelManager: packetTunnelManager)
            } header: {
                Text("状态")
            }
            Section {
                MPCPolicyGroupView(packetTunnelManager: packetTunnelManager)
            } header: {
                Text("代理")
            }
        }
        .formStyle(.grouped)
        .onChange(of: current) { newValue in
            packetTunnelManager.set(subscribe: newValue)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                MPSettingButton(packetTunnelManager: packetTunnelManager)
            }
        }
    }
}
