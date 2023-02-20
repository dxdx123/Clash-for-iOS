import SwiftUI

struct MPCTunnelModeView: View {
    
    let tunnelMode: Binding<MPCTunnelMode>
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    
    init(tunnelMode: Binding<MPCTunnelMode>, packetTunnelManager: MPPacketTunnelManager) {
        self.tunnelMode = tunnelMode
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
    }
    
    var body: some View {
        NavigationLink {
            MPFormPicker(title: "代理模式", selection: tunnelMode) {
                ForEach(MPCTunnelMode.allCases) { mode in
                    Text(mode.name)
                }
            }
        } label: {
            LabeledContent {
                Text(tunnelMode.wrappedValue.name)
            } label: {
                Label {
                    Text("代理模式")
                } icon: {
                    Image(systemName: "arrow.triangle.branch")
                }
            }
        }
        .onChange(of: tunnelMode.wrappedValue) { newValue in
            packetTunnelManager.set(tunnelMode: newValue)
        }
    }
}

extension MPCTunnelMode {
    
    var name: String {
        switch self {
        case .global:
            return "全局"
        case .rule:
            return "规则"
        case .direct:
            return "直连"
        }
    }
}
