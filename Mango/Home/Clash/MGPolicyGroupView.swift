import SwiftUI

struct MGPolicyGroupView: View {
    
    @ObservedObject private var packetTunnelManager: MGPacketTunnelManager
    
    @State private var isPresented = false
    
    init(packetTunnelManager: MGPacketTunnelManager) {
        self._packetTunnelManager = ObservedObject(wrappedValue: packetTunnelManager)
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
                switch packetTunnelManager.kernel {
                case .clash:
                    MGProviderListView(packetTunnelManager: packetTunnelManager)
                case .xray:
                    MGProviderListView(packetTunnelManager: packetTunnelManager)
                }
            }
        } label: {
            Label {
                switch packetTunnelManager.kernel {
                case .clash:
                    Text("策略组")
                case .xray:
                    Text("代理")
                }
            } icon: {
                Image(systemName: "square.3.layers.3d")
            }
        }
    }
}
