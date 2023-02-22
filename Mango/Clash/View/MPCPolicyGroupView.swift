import SwiftUI

struct MPCPolicyGroupView: View {
    
    @AppStorage(MGConstant.Clash.tunnelMode, store: .shared) private var tunnelMode = MPCTunnelMode.rule
    
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    @State private var isPresented = false
    
    init(packetTunnelManager: MPPacketTunnelManager) {
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
    }
    
    var body: some View {
        LabeledContent {
            Button {
                isPresented.toggle()
            } label: {
                Text("查看")
            }
            .disabled(packetTunnelManager.status != .connected)
            .sheet(isPresented: $isPresented) {
                MPCProviderListView(tunnelMode: tunnelMode, packetTunnelManager: packetTunnelManager)
            }
        } label: {
            Label {
                Text("策略组")
            } icon: {
                Image(systemName: "square.3.layers.3d")
            }
        }
    }
}
