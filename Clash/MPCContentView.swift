import SwiftUI
import NetworkExtension

struct MPCContentView: View {
        
    @AppStorage(CFIConstant.current,    store: .shared) private var current     = ""
    
    @StateObject private var packetTunnelManager    = MPPacketTunnelManager(kernel: .clash)
    @StateObject private var subscribeManager       = CFISubscribeManager()
    @StateObject private var databaseManager        = CFIGEOIPManager()
    
    var body: some View {
        Form {
            Section {
                CFISubscribeView(current: $current, packetTunnelManager: packetTunnelManager, subscribeManager: subscribeManager)
            } header: {
                Text("订阅")
            }
            Section {
                CFIControlView(packetTunnelManager: packetTunnelManager)
                CFIConnectedDurationView(packetTunnelManager: packetTunnelManager)
            } header: {
                Text("状态")
            }
            Section {
                LabeledContent {
                    CFIPolicyGroupView(packetTunnelManager: packetTunnelManager)
                } label: {
                    Label {
                        Text("策略组")
                    } icon: {
                        MPIcon(systemName: "square.3.layers.3d", backgroundColor: .teal)
                    }
                }
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
