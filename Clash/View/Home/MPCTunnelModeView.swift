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
                    makeLabel(mode: mode)
                }
            }
        } label: {
            LabeledContent {
                Text(tunnelMode.wrappedValue.name)
            } label: {
                Label {
                    Text("代理模式")
                } icon: {
                    MPIcon(systemName: "arrow.uturn.right", backgroundColor: .teal)
                }
            }
        }
        .onChange(of: tunnelMode.wrappedValue) { newValue in
            packetTunnelManager.set(tunnelMode: newValue)
        }
    }
    
    
    private func makeLabel(mode: MPCTunnelMode) -> some View {
        let title: String
        let systemImage: String
        let backgroundColor: Color
        switch mode {
        case .global:
            title = "全局"
            systemImage = "globe"
            backgroundColor = .blue
        case .rule:
            title = "规则"
            systemImage = "arrow.triangle.branch"
            backgroundColor = .orange
        case .direct:
            title = "直连"
            systemImage = "arrow.up"
            backgroundColor = .indigo
        }
        return Label {
            Text(title)
        } icon: {
            MPIcon(systemName: systemImage, backgroundColor: backgroundColor)
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
    
    var systemImage: String {
        switch self {
        case .global:
            return "globe"
        case .rule:
            return "arrow.triangle.branch"
        case .direct:
            return "arrow.up"
        }
    }
    
    var iconBackgroundColor: Color {
        switch self {
        case .global:
            return .blue
        case .rule:
            return .orange
        case .direct:
            return .indigo
        }
    }
}
