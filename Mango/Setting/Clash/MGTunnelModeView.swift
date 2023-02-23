import SwiftUI

struct MGTunnelModeView: View {
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    
    @AppStorage(MGConstant.Clash.tunnelMode, store: .shared) private var tunnelMode = MGTunnelMode.rule
    
    var body: some View {
        NavigationLink {
            MGFormPicker(title: "代理模式", selection: $tunnelMode) {
                ForEach(MGTunnelMode.allCases) { mode in
                    Text(mode.name)
                }
            }
        } label: {
            LabeledContent {
                Text(tunnelMode.name)
            } label: {
                Label {
                    Text("代理模式")
                } icon: {
                    Image(systemName: "arrow.triangle.branch")
                }
            }
        }
        .onChange(of: tunnelMode) { newValue in
            MGKernel.Clash.set(manager: packetTunnelManager, tunnelMode: newValue)
        }
    }
}

extension MGTunnelMode {
    
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
